--
-- hdl_string_format -- VHDL package to provide C-like string formatting
--
-- Copyright 1995, 2001 by Jan Decaluwe/Easics NV (under the name PCK_FIO)
-- Copyright 2016-2018 by Andre Souto (suoto)
--
-- This file is part of hdl_string_format.
--
-- hdl_string_format is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- hdl_string_format is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with hdl_string_format.  If not, see <http://www.gnu.org/licenses/>.

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
-- signed/unsigned definition: use either std_logic_arith or numeric_std
-- use ieee.std_logic_arith.all; -- the Synopsys one
use ieee.numeric_std.all;

package str_format_pkg is
    -- prefix string for hex output
    -- VHDL style:    "X"""
    -- Verilog style: "h'"
    -- C style:       "0x"
    constant FIO_h_PRE:  string := "0x";

    -- postfix string for hex output
    -- VHDL style:    """"
    constant FIO_h_POST: string := "";

    -- prefix string for bit vector output
    -- VHDL style:    "B"""
    -- Verilog style: "b'"
    constant FIO_bv_PRE:  string := "";

    -- postfix string for bit vector output
    -- VHDL style:    """"
    constant FIO_bv_POST: string := "";

    -- prefix string for bit output
    -- VHDL style:    "'"
    -- Verilog style: "b'"
    constant FIO_b_PRE:  string := "";

    -- postfix string for bit output
    -- VHDL style:    "'"
    constant FIO_b_POST: string := "";

    -- digit width for the string representation of integers
    constant FIO_d_WIDTH: integer := 10;

    -- bit width for the string representation of integers
    constant FIO_b_WIDTH: integer := 32;

    -- definition of the NIL string (default value for fprint arguments)
    -- fprint stops consuming arguments at the first NIL argument
    constant FIO_NIL: string := "\";

    procedure fprint (
                 L      : inout line;
        constant format : in    string;
        A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 : in string := FIO_NIL;
        A9 , A10, A11, A12, A13, A14, A15, A16: in string := FIO_NIL;
        A17, A18, A19, A20, A21, A22, A23, A24: in string := FIO_NIL;
        A25, A26, A27, A28, A29, A30, A31, A32: in string := FIO_NIL
        );

    function fo (constant arg: unsigned)          return string;
    function fo (constant arg: signed)            return string;
    function fo (constant arg: std_logic_vector)  return string;
    -- function fo (arg: std_ulogic_vector) return string;
    function fo (constant arg: bit_vector)        return string;
    function fo (constant arg: integer)           return string;
    function fo (constant arg: std_ulogic)        return string;
    function fo (constant arg: bit)               return string;
    function fo (constant arg: boolean)           return string;
    function fo (constant arg: character)         return string;
    function fo (constant arg: string)            return string;
    function fo (constant arg: time)              return string;

    -- procedure FIO_FormatExpand (
    --              fmt          : inout line;
    --     constant format       : in    string;
    --     constant start_pointer : in    positive);

    impure function sformat (
        constant format :  in  string;
        A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 : in string := FIO_NIL;
        A9 , A10, A11, A12, A13, A14, A15, A16: in string := FIO_NIL;
        A17, A18, A19, A20, A21, A22, A23, A24: in string := FIO_NIL;
        A25, A26, A27, A28, A29, A30, A31, A32: in string := FIO_NIL) return string;

end str_format_pkg;

package body str_format_pkg is

    --------------------------
    -- FIO Warnings support --
    --------------------------

    procedure FIO_Warning_Fsbla (
                 L       : inout line;
        constant format  : in    string;
        constant pointer : in    positive) is
    begin
        fprint (L, "\n** Warning: FIO_PrintLastValue: " &
        "format specifier beyond last argument\n");
        fprint (L, "**  in format string: ""%s""\n", format);
        fprint (L, "**                     ");
        for i in 1 to pointer-1 loop
            fprint (L, "-");
        end loop;
        fprint (L, "^\n");
    end FIO_Warning_Fsbla;

    procedure FIO_Warning_Ufs   (
                 L       : inout line;
        constant format  : in    string;
        constant pointer : in    positive;
        constant char    : in    character) is
    begin
        fprint (L, "\n** Warning: FIO_PrintArg: " &
        "Unexpected format specifier '%r'\n",
        fo(char));
        fprint (L, "**   in format string: ""%s""\n", format) ;
        fprint (L, "**                      ");
        for i in 1 to pointer-1 loop
            fprint (L, "-");
        end loop;
        fprint (L, "^\n**   Assuming 'q' to proceed: ");
    end FIO_Warning_Ufs;


    ----------------------------------
    -- bit conversion support --
    ----------------------------------

    type T_bit_map is array(bit) of character;

    constant C_BIT_MAP: T_bit_map := ('0', '1');

    ----------------------------------
    -- std_logic conversion support --
    ----------------------------------

    type T_std_logic_map is array(std_ulogic) of character;

    constant C_STD_LOGIC_MAP: T_std_logic_map := ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H',
                                                  '-');

    ------------------------------
    -- Digit conversion support --
    ------------------------------

    -- types & constants

    subtype S_digit_chars is character range '0' to '9';
    subtype S_digits      is integer   range  0  to  9 ;

    type T_digit_chars_map is array(S_digit_chars) of S_digits;

    constant C_DIGIT_CHARS_MAP: T_digit_chars_map := (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);

    type T_digits_map is array(S_digits) of S_digit_chars;

    constant C_DIGITS_MAP: T_digits_map  := ('0', '1', '2', '3', '4', '5', '6', '7', '8',
                                             '9');


    --------------------------------
    -- Decimal conversion support --
    --------------------------------

    -- unsigned to decimal

    function unsigned_to_decimal (
        constant arg      : string) return integer is
        constant argument : string(arg'length downto 1) := arg;
        variable result   : integer := 0;
    begin
        for i in argument'range loop
            case argument(i) is
                when '1'    => result := 2**(i-1) + result;
                when '0'    => null;
                when others => return(-1);
            end case;
        end loop;
        return (result);
    end unsigned_to_decimal;

    -- signed to decimal

    function signed_to_decimal (
        constant arg      : string) return integer is
        constant argument : string(arg'length downto 1) := arg;
        variable result   : integer := 0;
    begin
        case argument(argument'left) is
            when '1' =>    result := - 2**(argument'left-1);
            when '0' =>    result := 0;
            when others => return (integer'low);
        end case;

        for i in argument'left-1 downto 1 loop
            case argument(i) is
                when '1'    => result := 2**(i-1) + result;
                when '0'    => null;
                when others => return(integer'low);
            end case;
        end loop;
        return (result);
    end signed_to_decimal;

    -- string  to decimal

    function integer_to_decimal (
        constant arg    : string(1 to FIO_d_WIDTH+1)) return integer is
        constant sign   : character := arg(1);
        constant value  : string(arg'length-1 downto 1) := arg(2 to arg'length);
        variable char   : character;
        variable result : integer := 0;
    begin
        result := 0;
        for i in value'range loop
            result := result * 10;
            char := value(i);
            if (char /= ' ') then
                result := result + C_DIGIT_CHARS_MAP(char);
            end if;
        end loop;

        case sign is
            when '-'    => return(-result);
            when others => return(result);
        end case;
    end integer_to_decimal;

    -- boolean (0,1) to decimal

    function bool_to_decimal (
        constant arg: string(1 to 1)) return integer is
    begin
        case arg is
            when "1"    => return(1);
            when "0"    => return(0);
            when others => return(-1);
        end case;
    end bool_to_decimal;

    -- boolean (T,F) to decimal

    function true_or_false_to_decimal (
        constant arg: string(1 to 1)) return integer is
    begin
        case arg is
            when "T"    => return(1);
            when others => return(0);
        end case;
    end true_or_false_to_decimal;



    ----------------------------
    -- Hex conversion support --
    ----------------------------

    -- Constants & types

    constant C_HEX_CHARS: string(1 to 17) := "0123456789ABCDEF?";

    -- Function to return Hex index of a nibble

    function U_To_h_Index(
        constant arg: string(4 downto 1)) return integer is
        variable index: integer := 0;
    begin
        for i in arg'range loop
            case arg(i) is
                when '1'    => index := 2**(i-1) + index;
                when '0'    => null;
                when others => return (17);
                end case;
            end loop;
        return (index+1);
    end U_To_h_Index;

    -- Hex conversion

    function U_To_h (
        constant arg    : string) return string is
        variable result : string((arg'length-1)/4 +1 downto 1);
        variable extarg : string(result'length*4 downto 1) := (others => '0');
    begin
        extarg(arg'length downto 1) := arg;
        for i in result'range loop
            result(i) := C_HEX_CHARS(U_To_h_Index( extarg(i*4 downto i*4 -3) ));
        end loop;
        return (FIO_h_PRE & result & FIO_h_POST);
    end U_To_h;



    ----------------------------
    -- Bit conversion support --
    ----------------------------

    function L_To_b (
        constant arg    : string(1 to 1)) return string is
        variable result : string(1 to 1);
    begin
        case arg is
            when "T"    => result := "1";
            when others => result := "0";
        end case;
        return(FIO_b_PRE & result & FIO_b_POST);
    end L_To_b;


    function I_To_b (
        constant arg              : string(1 to FIO_d_WIDTH+1);
        constant justified        : side;
        constant width            : integer) return string is
        constant blanks           : string(1 to FIO_b_WIDTH) := (others => ' ');
        variable intvalue         : integer := integer_to_decimal(arg);
        variable bitvalue         : string(1 to FIO_b_WIDTH) := (others => ' ');
        variable sign             : character := ' ';
        variable bitwidth         : integer range 0 to FIO_b_WIDTH;
        variable mspos            : integer range 1 to bitvalue'length;
        variable bitvalueextended : string(1 to 2*FIO_b_WIDTH);

    begin

        if (intvalue < 0) then
            sign     := '-';
            intvalue := -intvalue;
        end if;

        for i in bitvalue'reverse_range loop
            bitvalue(i) := C_DIGITS_MAP(intvalue mod 2);
            intvalue := intvalue / 2;
            exit when (intvalue = 0);
        end loop;

        bitvalueextended := bitvalue & blanks;

        if (width = 0) or (width > FIO_b_WIDTH+1) then
            bitwidth := FIO_b_WIDTH;
        else
            bitwidth := width-1;
        end if;

        if (justified = RIGHT) then
            return (FIO_bv_PRE & sign &
                    bitvalue(bitvalue'length-bitwidth+1 to bitvalue'length) &
                    FIO_bv_POST);
        else
            for i in bitvalue'range loop
                if bitvalue(i) /= ' ' then
                    mspos := i;
                    exit;
                end if;
            end loop;
            return (FIO_bv_PRE & sign &
                    bitvalueextended(mspos to mspos+bitwidth-1) &
                    FIO_bv_POST);
        end if;

    end I_To_b;


    -----------------------------------
    -- Reasonable conversion support --
    -----------------------------------

    function I_To_r (
        constant arg           : string(1 to FIO_d_WIDTH+1);
        constant justified     : side;
        constant width         : integer) return string is
        constant value         : string(1 to FIO_d_WIDTH) := arg(2 to FIO_d_WIDTH+1);
        constant sign          : character := arg(1);
        constant blanks        : string(1 to FIO_d_WIDTH) := (others => ' ');
        variable intwidth      : integer range 0 to FIO_d_WIDTH;
        variable mspos         : integer range 1 to value'length;
        variable valueextended : string(1 to 2*FIO_d_WIDTH) := value & blanks;
    begin
        if (width = 0) or (width > FIO_d_WIDTH+1) then
            intwidth := FIO_d_WIDTH;
        else
            intwidth := width-1;
        end if;
        if (justified = RIGHT) then
            return (sign & value(value'length-intwidth+1 to value'length));
        else
            for i in value'range loop
                if value(i) /= ' ' then
                    mspos := i;
                    exit;
                end if;
            end loop;
            return (sign & valueextended(mspos to mspos+intwidth-1));
        end if;
    end I_To_r;


    -------------------------------------------
    -- Reasonable output conversion function --
    -------------------------------------------

    function ReasonableOutput (
        constant arg       : string;
        constant justified : side;
        constant width     : integer) return string is
        constant argument  : string(1 to arg'length) := arg;
        constant typespec  : string (1 to 2) := argument(1 to 2);
        constant value     : string(1 to arg'length-2) := argument(3 to arg'length);
    begin
        case typespec is
            when "U:" | "S:" | "V:" =>
                return U_To_h(value);
            when "I:" =>
                return I_To_r(value, justified, width);
            when "B:" | "L:" | "C:" =>
                return value;
            when others =>
                return argument;
        end case;

    end ReasonableOutput;


    ------------------------------------
    -- Bit output conversion function --
    ------------------------------------

    function BitOutput (
        constant arg       : string;
        constant justified : side;
        constant width     : integer) return string is
        constant argument  : string(1 to arg'length) := arg;
        constant typespec  : string (1 to 2) := argument(1 to 2);
        constant value     : string(1 to arg'length-2) := argument(3 to arg'length);
    begin
        case typespec is
            when "U:" | "S:" | "V:" =>
                return (FIO_bv_PRE & value & FIO_bv_POST);
            when "B:" =>
                -- value(1 to 1) instead of value for LeapFrog
                return (FIO_b_PRE & value(1 to 1) & FIO_b_POST);
            when "I:" =>
                return I_To_b(value, justified, width);
            when "L:"  =>
                -- value(1 to 1) instead of value for LeapFrog
                return L_To_b(value(1 to 1));
            when others =>
                return argument;
        end case;

    end BitOutput;


    -------------------------------------------
    -- Decimal output conversion function --
    -------------------------------------------

    function DecimalOutput (
        constant arg      : string) return integer is
        constant argument : string(1 to arg'length) := arg;
        constant typespec : string (1 to 2) := argument(1 to 2);
        constant value    : string(1 to arg'length-2) := argument(3 to arg'length);
    begin
        case typespec is
            when "U:"| "V:" =>
                return unsigned_to_decimal(value);
            when "S:" =>
                return signed_to_decimal(value);
            when "I:" =>
                return integer_to_decimal(value);
            when "B:" =>
                return bool_to_decimal(value);
            when "L:" =>
                return true_or_false_to_decimal(value);
            when others =>
                return integer'low;
        end case;

    end DecimalOutput;


    ----------------------------
    -- Atomic print functions --
    ----------------------------

    -- test for end of format string

    function FIO_EOS (
        constant format: in string;
        constant pointer: in integer) return boolean is
    begin
        return (pointer > format'length);
    end FIO_EOS;


    -- Atomic value print function

    procedure FIO_PrintValue (
                 L       : inout line;
        constant format  : in    string;
                 pointer : inout integer;
        constant Last    : in    boolean := False) is
        variable char    : character;
    begin
        while (not FIO_EOS(format, pointer)) loop
            char := format(pointer);
            case char is
                when '\' =>
                    pointer := pointer + 1;
                    exit when (FIO_EOS(format, pointer));
                    char := format(pointer);
                    write(L, char);
                when '%' =>
                    pointer := pointer + 1;
                    exit;
                when others  =>
                    write(L, char);
                end case;
            pointer := pointer + 1;
        end loop;
    end FIO_PrintValue;


    ---- Atomic argument print function

    procedure FIO_PrintArg (
                 L         : inout line;
        constant format    : in    string;
                 pointer   : inout integer;
        constant arg       : in    string) is
        variable char      : character;
        variable justified : side;
        variable width     : integer;

    begin

    FIO_PrintValue(L, format, pointer);

    justified := RIGHT;
    width := 0;
    while (not FIO_EOS(format, pointer)) loop
        char := format(pointer);
        case char is
            when '-' =>
                justified := LEFT;
                pointer := pointer + 1;
            when '0' to '9' =>
                width := width*10 + C_DIGIT_CHARS_MAP(char);
                pointer := pointer + 1;
            when 'r' =>
                write(L, ReasonableOutput(arg, justified, width), justified, width);
                pointer := pointer + 1;
                exit;
            when 'b' =>
                write(L, BitOutput(arg, justified, width), justified, width);
                pointer := pointer + 1;
                exit;
            when 'd' =>
                write(L, DecimalOutput(arg), justified, width);
                pointer := pointer + 1;
                exit;
            when 'q' | 's' =>
                write(L, arg, justified, width);
                pointer := pointer + 1;
                exit;
            when others  =>
                -- FIO_Warning_Ufs(F, L, format, pointer, char);
                write(L, arg, justified, width);
                pointer := pointer + 1;
                exit;
        end case;
    end loop;
    end FIO_PrintArg;


    -----------------------------------------------------
    -- The format string iteration expansion procedure --
    -----------------------------------------------------

    procedure FIO_FormatExpand (
             fmt            : inout line;
    constant format         : in    string;
    constant start_pointer  : in    positive) is
    variable pointer        : positive := start_pointer;
    variable token_start    : positive;
    variable iter_str_start : positive;
    variable iter_str_end   : positive;
    variable iter_cnt       : natural;
    variable open_brackets  : natural;
    variable L              : line;

    begin

        FORMAT_SEARCH: while not FIO_EOS(format, pointer) loop

            case format(pointer) is

            -- look for format specifier
            when '%' =>

            -- initialize iteration token search
            token_start := pointer;
            iter_cnt := 0;
            pointer := pointer + 1;

            -- start iteration token search
            TOKEN_READ: while not FIO_EOS(format, pointer) loop

            case format(pointer) is

                -- read iteration counter
                when '0' to '9' =>
                    iter_cnt := iter_cnt*10 + C_DIGIT_CHARS_MAP(format(pointer));
                    pointer := pointer + 1;

                -- expect open bracket
                when '{' =>

                    -- initialize iteration string read
                    open_brackets := 1;
                    iter_str_start := pointer + 1;
                    pointer := pointer + 1;
                    -- quit prematurely when iteration count is 0
                    next FORMAT_SEARCH when (iter_cnt = 0);

                    -- start iteration string read
                    ITER_STRING_READ: while not FIO_EOS(format, pointer) loop

                        case format(pointer) is
                            -- keep track of open brackets
                            when '{' =>
                                open_brackets := open_brackets + 1;
                                pointer := pointer + 1;
                                -- when closing bracket is found, process iteration string
                            when '}' =>
                                open_brackets := open_brackets - 1;
                                if (open_brackets = 0) then
                                    iter_str_end := pointer-1;
                                    if (token_start /= 1) then
                                        write(L, format(1 to token_start-1));
                                    end if;
                                    for i in 1 to iter_cnt loop
                                        write(L,  format(iter_str_start to iter_str_end));
                                    end loop;
                                    if (iter_str_end /= format'length) then
                                        write(L, format(iter_str_end+2 to format'length));
                                    end if;
                                    -- call expansion procedure recursively on expanded format
                                    FIO_FormatExpand(fmt, L.all, token_start);
                                    deallocate(L);
                                    return;
                                end if;
                                pointer := pointer + 1;
                            -- skip escaped characters
                            when '\' =>
                                pointer := pointer + 2;
                            -- read iteration string
                            when others =>
                                pointer := pointer + 1;

                        end case;

                    end loop ITER_STRING_READ;

                -- stop iteration token search when no opening bracket found
                when others =>
                pointer := pointer + 1;
                next FORMAT_SEARCH;

            end case;

            end loop TOKEN_READ;

            -- skip escaped characters
            when '\' =>
                pointer := pointer + 2;

            -- read other characters
            when others =>
                pointer := pointer + 1;

            end case;

        end loop FORMAT_SEARCH;

        write(fmt, format);
        deallocate(L);

    end FIO_FormatExpand;



    --------------------------
    -- The fprint procedure --
    --------------------------

    procedure fprint (
                 L       : inout line;
        constant format  : in    string;

        A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 : in string := FIO_NIL;
        A9 , A10, A11, A12, A13, A14, A15, A16: in string := FIO_NIL;
        A17, A18, A19, A20, A21, A22, A23, A24: in string := FIO_NIL;
        A25, A26, A27, A28, A29, A30, A31, A32: in string := FIO_NIL) is

        variable pointer : integer;
        variable fmt     : line;

    begin

        pointer := 1;

        FIO_FormatExpand (fmt, format, format'low);

        if (A1  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A1 );
        if (A2  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A2 );
        if (A3  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A3 );
        if (A4  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A4 );
        if (A5  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A5 );
        if (A6  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A6 );
        if (A7  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A7 );
        if (A8  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A8 );
        if (A9  /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A9 );
        if (A10 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A10);
        if (A11 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A11);
        if (A12 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A12);
        if (A13 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A13);
        if (A14 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A14);
        if (A15 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A15);
        if (A16 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A16);
        if (A17 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A17);
        if (A18 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A18);
        if (A19 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A19);
        if (A20 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A20);
        if (A21 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A21);
        if (A22 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A22);
        if (A23 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A23);
        if (A24 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A24);
        if (A25 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A25);
        if (A26 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A26);
        if (A27 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A27);
        if (A28 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A28);
        if (A29 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A29);
        if (A30 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A30);
        if (A31 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A31);
        if (A32 /= FIO_NIL) then FIO_PrintArg(L, fmt.all, pointer, A32);
        end if; end if; end if; end if; end if; end if; end if; end if;
        end if; end if; end if; end if; end if; end if; end if; end if;
        end if; end if; end if; end if; end if; end if; end if; end if;
        end if; end if; end if; end if; end if; end if; end if; end if;

        FIO_PrintValue(L, fmt.all, pointer, Last => TRUE);

        deallocate(fmt);

    end fprint;


    -------------------------------------------
    -- Formatted output conversion functions --
    -------------------------------------------

    function fo (
        constant arg      : unsigned) return string is
        constant argument : unsigned(1 to arg'length) := arg;
        variable result   : string(1 to arg'length);
    begin
        for i in argument'range loop
            result(i) := C_STD_LOGIC_MAP(argument(i));
        end loop;
        return ("U:" & result);
    end fo;

    function fo (
        constant arg      : signed) return string is
        constant argument : signed(1 to arg'length) := arg;
        variable result   : string(1 to arg'length);
    begin
        for i in argument'range loop
            result(i) := C_STD_LOGIC_MAP(argument(i));
        end loop;
        return ("S:" & result);
    end fo;

    function fo (
        constant arg      : std_logic_vector) return string is
        constant argument : std_logic_vector(1 to arg'length) := arg;
        variable result   : string(1 to arg'length);
    begin
        for i in argument'range loop
            result(i) := C_STD_LOGIC_MAP(argument(i));
        end loop;
        return ("V:" & result);
    end fo;

    -- function fo (arg: std_ulogic_vector) return string is
    --   constant argument: std_ulogic_vector(1 to arg'length) := arg;
    --   variable result: string(1 to arg'length);
    -- begin
    --   for i in argument'range loop
    --     result(i) := C_STD_LOGIC_MAP(argument(i));
    --   end loop;
    --   return ("V:" & result);
    -- end fo;

    function fo (
        constant arg      : bit_vector) return string is
        constant argument : bit_vector(1 to arg'length) := arg;
        variable result   : string(1 to arg'length);
    begin
        for i in argument'range loop
            result(i) := C_BIT_MAP(argument(i));
        end loop;
        return ("V:" & result);
    end fo;

    function fo (
        constant arg      : integer) return string is
        variable argument : integer := arg;
        variable result   : string(1 to FIO_d_WIDTH) := (others => ' ');
        variable sign     : character := ' ';
    begin
        if (argument < 0) and (argument /= integer'low) then
            sign     := '-';
            argument := -argument;
        end if;
        for i in result'reverse_range loop
            result(i) := C_DIGITS_MAP(argument mod 10);
            argument  := argument / 10;
            exit when (argument = 0);
        end loop;
        return ("I:" & sign & result);
    end fo;

    function fo (
        constant arg: std_ulogic) return string is
    begin
        return ("B:" & C_STD_LOGIC_MAP(arg));
    end fo;

    function fo (
        constant arg: bit) return string is
    begin
        return ("B:" & C_BIT_MAP(arg));
    end fo;

    function fo (
        constant arg: boolean) return string is
    begin
        if (ARG = TRUE) then
            return ("L:T");
        else
            return ("L:F");
        end if;
    end fo;

    function fo (
        constant arg : character) return string is
    begin
        return ("C:" & arg);
    end fo;

    -- auxilary function fgets(arg :string)
    -- returns index of first NUL in arg or if no NUL is present just arg'length
    -- goes through arg from 1 to arg'length
    function fgets (
        constant arg   : string) return integer is
        variable index : integer := arg'length;
    begin
        for i in 1 to arg'length loop
            if arg(i) = NUL then
                index := i - 1;
                exit;
            else
                null;
            end if;
        end loop;
        return index;
    end fgets;

    -- returns the arg string until the first NUL was encountered
    -- if fo is used on a string with NUL in it it will stop reading the rest
    -- of the string, even if a larger field width has been supplied.  fo will
    -- then just pad the remaining characters with blanco's
    function fo (
        constant arg : string) return string is
    begin
        return arg(1 to fgets(arg));
    end fo;

    function fo (
        constant arg: time) return string is
    begin
        return fo (integer (arg / 1 ns));
    end fo;


    --
    --
    --

    impure function sformat (
        constant format : in    string;
        A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 : in string := FIO_NIL;
        A9 , A10, A11, A12, A13, A14, A15, A16: in string := FIO_NIL;
        A17, A18, A19, A20, A21, A22, A23, A24: in string := FIO_NIL;
        A25, A26, A27, A28, A29, A30, A31, A32: in string := FIO_NIL
        ) return string is
        variable L      : line;

        -- A helper function to prevent memory leaks.
        -- Similar solution as in https://stackoverflow.com/a/42716392
        impure function line_to_string return string is
            variable ret : string (1 to L'length);
        begin
            ret := L.all;
            deallocate(L);
            return ret;
        end function;

    begin
        fprint (L,
            format,
            A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 ,
            A9 , A10, A11, A12, A13, A14, A15, A16,
            A17, A18, A19, A20, A21, A22, A23, A24,
            A25, A26, A27, A28, A29, A30, A31, A32);

        return line_to_string;
    end function;

end str_format_pkg;

