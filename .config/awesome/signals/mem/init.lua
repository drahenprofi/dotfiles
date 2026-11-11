local watch = require("awful.widget.watch")
local naughty = require("naughty")

--CMD = [[bash -c "free -h | awk 'NR==2{gsub(/Gi/, \"\", $2); gsub(/Gi/, \"\", $3); printf \"%.1f/%.f GiB\n%.4f\", $3, $2, $3/$2}'"]]
CMD = [[bash -c "free --mega | awk 'NR==2{printf \"%.1f/%.1f GB\n%.4f\", $3/1000, $2/1000, $3/$2}'"]]

watch(CMD, 10, function(widget, stdout, stderr, exitreason, exitcode)
    result = {}
    
    i = 1
    for s in stdout:gmatch("[^\r\n]+") do
        result[i] = s
        i = i+1
    end

    awesome.emit_signal("evil::mem", {
        value = result[2], 
        text = result[1] 
    })
end)