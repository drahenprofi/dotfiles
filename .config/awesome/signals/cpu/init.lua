local watch = require("awful.widget.watch")

CMD = [[sh -c "cat <(grep 'cpu ' /proc/stat) <(sleep 1 && grep 'cpu ' /proc/stat) | awk -v RS="" '{print ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5)}'"]]


watch(CMD, 5, function(widget, stdout, stderr, exitreason, exitcode)
    awesome.emit_signal("evil::cpu", {
        value = stdout
    })
end,
nil)