-- SPDX-License-Identifier: BSD-3-Clause

local glog = {}

function glog.init()
	global.glog = {}
end

function glog.log(msg)
	if type(msg) == "table" then
		msg = serpent.block(msg)
	end
	table.insert(global.glog, game.tick..": "..msg)
end

function glog.save(cmd)
	game.write_file("glog-"..game.tick..".txt", table.concat(global.glog, "\n"))
	global.glog = {}
end

commands.add_command("gsave", nil, glog.save)
commands.add_command("glog", nil, function(command)
	glog.log(command.parameter)
end)

return glog
