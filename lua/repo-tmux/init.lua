local function get_last_element(inputstr)
	local lastElement = nil
	for str in string.gmatch(inputstr, "([^/]+)") do
		lastElement = str
	end
	return lastElement
end

local M = {}

local terminal_state = {}

local function create_window()
	vim.api.nvim_command("botright split")
	local win_handle = vim.api.nvim_get_current_win()
	terminal_state.open_win_handle = win_handle
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win_handle),
		callback = function(ev)
			terminal_state.open_win_handle = nil
		end,
	})
end

local function kill_window()
	vim.api.nvim_win_close(terminal_state.open_win_handle, true)
end

local function is_window_open()
	return terminal_state.open_win_handle ~= nil
end

local function create_term_buffer()
	local oldHandle = terminal_state.buf_handle
	local buf_handle = vim.api.nvim_create_buf(false, true)

	terminal_state.buf_handle = buf_handle

	local file_path = vim.fn.expand("%:p")
	local file_dir = vim.fn.fnamemodify(file_path, ":h")
	local git_root_cmd = "git -C " .. file_dir .. " rev-parse --show-toplevel"
	local git_root = vim.fn.system(git_root_cmd):gsub("\n", "")

	local lastElement = get_last_element(git_root)
	local tmux_session_name = string.format('"%s (%s)"', lastElement, git_root)
	local tmux_cmd = "cd " .. git_root .. " && tmux new-session -A -s " .. tmux_session_name

	vim.api.nvim_win_set_buf(terminal_state.open_win_handle, buf_handle)

	vim.api.nvim_set_current_win(terminal_state.open_win_handle)
	vim.fn.termopen(tmux_cmd, { cwd = git_root })

	vim.cmd(":startinsert")

	if oldHandle then
		vim.api.nvim_buf_delete(oldHandle, { force = true })
	end
end

function M.open()
	if is_window_open() == false then
		create_window()
	end
	create_term_buffer()
end

function M.close()
	kill_window()
end

local function setupCommands()
	local command = vim.api.nvim_create_user_command

	command("RepoTmuxOpen", function()
		M.open()
	end, {})

	command("RepoTmuxClose", function()
		M.close()
	end, {})
end

function M.setup()
	setupCommands()
end

return M
