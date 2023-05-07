local M = {}

local function check_for_new_prs(user)
  local command = string.format("gh search prs --assignee %s --json number,title,url", user)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  local data = vim.json.decode(result)

  if #data > 0 then
    local message = string.format("New PRs assigned to %s:", user)
    for _, pr in ipairs(data) do
      message = string.format("%d. %s (%s)", pr.number, pr.title, pr.url)
      vim.notify(message)
    end
  end
end

local function get_gh_username()
  local handle = io.popen("gh api user")
  local result = handle:read("*a")
  handle:close()

  return vim.json.decode(result)
end

function M.setup(opts)
  local user = get_gh_username()
  local interval = opts.interval or 60
  local start_after = opts.start_after or 10

  local timer = vim.loop.new_timer()
  timer:start(start_after * 1000, interval * 1000, vim.schedule_wrap(function() check_for_new_prs(user.login) end))
end

return M