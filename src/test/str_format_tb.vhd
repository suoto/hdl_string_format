--
-- hdl_string_format -- VHDL package to provide C-like string formatting
--
-- Copyright 1995, 2001 by Jan Decaluwe/Easics NV (under the name PCK_FIO)
-- Copyright 2016 by Andre Souto (suoto)
--
-- This file is part of hdl_string_format.

-- hdl_string_format is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- hdl_string_format is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with hdl_string_format.  If not, see <http://www.gnu.org/licenses/>.
--
--
---------------
-- Libraries --
---------------
use std.textio.all;
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;

library str_format;
    use str_format.str_format_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity str_format_tb is
    generic (runner_cfg : string);
end entity;

architecture tb of str_format_tb is

    ---------------
    -- Constants --
    ---------------

    -------------
    -- Signals --
    -------------

begin
    -------------------
    -- Port mappings --
    -------------------

    -----------------------------
    -- Asynchronous assignments --
    -----------------------------
    test_runner_watchdog(runner, 10 ms);

    ---------------
    -- Processes --
    ---------------
    main : process
        variable stat   : checker_stat_t;

        --
        variable L       : line;
        variable pointer : integer := 1;
    -- begin

        -- variable value : std_logic_vector(15 downto 0);
        constant value : std_logic_vector(15 downto 0) := x"1234";

        impure function mycolorize (
            constant attributes : string) return string is
            variable lines      : lines_t := split(attributes, " ");
            constant attr_cnt   : integer := lines'length;
            variable attr       : line;
        begin
            for i in 0 to attr_cnt - 1 loop
                if lines(i).all = "blink"             then write(attr, string'("5"));
                elsif lines(i).all = "bold"           then write(attr, string'("1"));
                elsif lines(i).all = "dim"            then write(attr, string'("2"));
                elsif lines(i).all = "reverse"        then write(attr, string'("7"));
                elsif lines(i).all = "highlight"      then write(attr, string'("7"));
                elsif lines(i).all = "highlight-off"  then write(attr, string'("27"));
                elsif lines(i).all = "underline"      then write(attr, string'("4"));
                elsif lines(i).all = "underline-off"  then write(attr, string'("24"));
                elsif lines(i).all = "black"          then write(attr, string'("30"));
                elsif lines(i).all = "red"            then write(attr, string'("31"));
                elsif lines(i).all = "green"          then write(attr, string'("32"));
                elsif lines(i).all = "yellow"         then write(attr, string'("33"));
                elsif lines(i).all = "blue"           then write(attr, string'("34"));
                elsif lines(i).all = "magenta"        then write(attr, string'("35"));
                elsif lines(i).all = "cyan"           then write(attr, string'("36"));
                elsif lines(i).all = "gray"           then write(attr, string'("37"));
                elsif lines(i).all = "bg-black"       then write(attr, string'("40"));
                elsif lines(i).all = "bg-red"         then write(attr, string'("41"));
                elsif lines(i).all = "bg-green"       then write(attr, string'("42"));
                elsif lines(i).all = "bg-yellow"      then write(attr, string'("43"));
                elsif lines(i).all = "bg-blue"        then write(attr, string'("44"));
                elsif lines(i).all = "bg-magenta"     then write(attr, string'("45"));
                elsif lines(i).all = "bg-cyan"        then write(attr, string'("46"));
                elsif lines(i).all = "bg-gray"        then write(attr, string'("47"));
                elsif lines(i).all = "reset"          then write(attr, string'("0"));
                else
                    report "Invalid attribute name " & lines(i).all
                        severity Error;
                end if;

                if i /= attr_cnt - 1 then
                    write(attr, string'(";"));
                else
                    write(attr, string'("m"));
                end if;


            end loop;
            -- info("attributes: " & attr.all);
            return esc & "[" & attr.all;
        end function;

        procedure cinfo(
            constant message : string) is
        begin
            write(output, mycolorize("green"));
            info(message & mycolorize("reset"));
            -- write(output, mycolorize("reset"));
        end procedure;

        procedure cwarn(
            constant message : string) is
        begin
            write(output, mycolorize("yellow"));
            warning(message & mycolorize("reset"));
            -- write(output, mycolorize("reset"));
        end procedure;


    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop
            check_equal(
                sformat("Call with no arguments"),
                        "Call with no arguments");

            check_equal(
               sformat("Special characters: \% \\ "),
                       "Special characters: % \ ");

            check_equal(
                sformat("Reasonable output (integer): %r", fo(4660)),
                        "Reasonable output (integer):        4660");

            check_equal(
                sformat("Reasonable output (std_logic_vector): %r", fo(std_logic_vector'(x"1234"))),
                        "Reasonable output (std_logic_vector): 0x1234");

            check_equal(
                sformat("Reasonable output (unsigned): %r", fo(unsigned'(x"1234"))),
                        "Reasonable output (unsigned): 0x1234");

            check_equal(
                sformat("Reasonable output (signed): %r", fo(signed'(x"1234"))),
                        "Reasonable output (signed): 0x1234");

           --  -- value := std_logic_vector(to_unsigned(16#1234#, 16));
           --  cinfo(sformat("Reasonable representation           %r", fo(value)));
           --  info(sformat("Binary representation               %b", fo(value)));
           --  cinfo(sformat("Decimal representation:             %d", fo(value)));
           --  info(sformat("String representation               %s", fo(value)));
           --  cinfo(sformat("qualified (internal) representation %q", fo(value)));
        end loop;

        if not active_python_runner(runner_cfg) then
            get_checker_stat(stat);
            cinfo(LF & "Result:" & LF & to_string(stat));
        end if;

        test_runner_cleanup(runner);
        wait;
    end process;

end architecture;

