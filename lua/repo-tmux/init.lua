local function get_last_element(inputstr)
	local lastElement = nil
	for str in string.gmatch(inputstr, "([^/]+)") do
		lastElement = str
	end
	return lastElement
end

local M = {
	setup = function(opts)
		print("setup")
		print(opts)
	end,
	open = function() end,
}

local terminal_state = {}

local function on_win_close()
	terminal_state.open_win_handle = nil
end

local function create_window()
	vim.api.nvim_command("botright split")
	local win_handle = vim.api.nvim_get_current_win()
	terminal_state.open_win_handle = win_handle
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win_handle),
		callback = function(ev)
			print("callback called")
			terminal_state.open_win_handle = nil
		end,
	})
end

local function kill_window()
	vim.api.nvim_win_close(terminal_state.open_win_handle, true)
end

local function kill_term_buffer()
	vim.api.nvim_buf_delete(terminal_state.buf_handle, { force = false })
end

local function create_term_buffer()
	local buf_handle = vim.api.nvim_create_buf(false, true)

	local oldHandle = terminal_state.buf_handle

	terminal_state.buf_handle = buf_handle

	local file_path = vim.fn.expand("%:p")
	local file_dir = vim.fn.fnamemodify(file_path, ":h")
	local git_root_cmd = "git -C " .. file_dir .. " rev-parse --show-toplevel"
	local git_root = vim.fn.system(git_root_cmd):gsub("\n", "")

	local lastElement = get_last_element(git_root)
	local tmux_session_name = string.format('"%s (%s)"', lastElement, git_root)
	print(tmux_session_name)
	local tmux_cmd = "cd " .. git_root .. " && tmux new-session -A -s " .. tmux_session_name

	vim.api.nvim_win_set_buf(terminal_state.open_win_handle, buf_handle)

	-- vim.api.nvim_set_current_buf(buf_handle)
	vim.api.nvim_set_current_win(terminal_state.open_win_handle)
	vim.fn.termopen(tmux_cmd, { cwd = git_root })
	-- vim.api.nvim_command(":terminal " .. tmux_cmd)

	vim.cmd(":startinsert")

	if oldHandle then
		vim.api.nvim_buf_delete(oldHandle, { force = true })
	end
end

function M.open()
	if terminal_state.open_win_handle then
		-- kill_term_buffer()
		-- kill_window()
		-- M.open()
		create_term_buffer()
	else
		create_window()
		create_term_buffer()
	end
end

function M.close()
	kill_window()
end

-- function M.open()
-- 	local file_path = vim.fn.expand("%:p")
--
-- 	local file_dir = vim.fn.fnamemodify(file_path, ":h")
--
-- 	local git_root_cmd = "git -C " .. file_dir .. " rev-parse --show-toplevel"
-- 	local git_root = vim.fn.system(git_root_cmd):gsub("\n", "")
--
-- 	-- local git_root = vim.fn.system(git_root_cmd):gsub("\n", "")
-- 	--
-- 	local lastElement = get_last_element(git_root)
--
-- 	local tmux_session_name = string.format('"%s (%s)"', lastElement, git_root)
--
-- 	print(tmux_session_name)
--
-- 	local tmux_cmd = "cd " .. git_root .. " && tmux new-session -A -s " .. tmux_session_name
--
-- 	-- local tmux_cmd = "tmux new-session -A -s " .. git_root
--
-- 	-- vim.api.nvim_command(":terminal " .. tmux_cmd)
-- 	-- vim.cmd(":startinsert")
--
-- 	vim.api.nvim_command("botright split")
--
-- 	local window = vim.api.nvim_get_current_win()
-- 	local bufnr = vim.api.nvim_create_buf(false, false)
--
-- 	terminal_state[bufnr] = {
-- 		bufnr = bufnr,
-- 		window = window,
-- 	}
--
-- 	self.current_buf = bufnr
--
-- 	print(self.current_buf)
--
-- 	vim.api.nvim_win_set_buf(window, bufnr)
--
-- 	vim.api.nvim_open_term(bufnr, {})
--
-- 	vim.api.nvim_command(":terminal " .. tmux_cmd)
--
-- 	vim.cmd(":startinsert")
--
-- 	-- vim.fn.termopen({ tmux_cmd }, { cwd = git_root })
--
-- 	-- current_buf = vim.api.nvim_create_buf(true, false)
-- end

return M
