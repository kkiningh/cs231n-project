`ifndef TEST_H_
`define TEST_H_

`define TB_ARG(_name, _default, _type, _format) \
    _type _name = _default; \
    initial begin \
        $value$plusargs({`"_name=`", _format}, _name); \
    end

`define TB_ARG_INT(_name, _default) `TB_ARG(_name, _default, int, "%d")
`define TB_ARG_STR(_name, _default) `TB_ARG(_name, _default, string, "%s")

`define SETUP_LOGGING(_default) `TB_ARG_INT(log_level, _default)

`define LOG(_msg, _type, _level) \
    do if (_log_level > _level) begin \
        $display({_type, ": [%t]: %s"}, $time, $sformatf _msg); \
    end while(0)

`define DEBUG(_msg)     `LOG(_msg, "DEBUG", 3)
`define INFO(_msg)      `LOG(_msg, "INFO ", 2)
`define WARN(_msg)      `LOG(_msg, "WARN ", 1)
`define ERROR(_msg)     `LOG(_msg, "ERROR", 0)

`ifndef NO_VPD
`define SETUP_VPD(_levels, _scope) \
    initial begin \
        if ($test$plusargs("vcdpluson")) begin \
            $vcdplusmemon; \
            $vcdplusdeltacycleon; \
            $vcdpluson(_levels, _scope); \
        end \
    end
`else
`define SETUP_VPD(_levels, _scope)
`endif

`define CLOCK_GEN(_clock_variable, _half_period) \
    reg _clock_variable; \
    initial begin \
        _clock_variable = 0; \
        forever begin \
            #_half_period _clock_variable = !_clock_variable; \
        end \
    end

`define WAIT_CYCLES(_cycles, _clock) \
    do begin repeat (_cycles) @(posedge _clock) begin end end while(0)

`endif
