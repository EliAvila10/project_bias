with Windows_Data_Types;

with Ada.Real_Time;

package Chain_Generator with SPARK_Mode => On is

   use Windows_Data_Types;

   subtype sub_entropy       is Float   range 0.0 .. 8.0
     with Static_Predicate => sub_entropy in 0.0 .. 8.0;

   subtype Alphanumeric_Mixed is String
     with Dynamic_Predicate =>
       (for all Mixed in Alphanumeric_Mixed'Range =>
          Alphanumeric_Mixed (Mixed)
              in '0' .. '9' | 'A' .. 'Z' | 'a' .. 'z'
                | '!' | '@' | '#' | '%' | '_' | '-' | '*');

   procedure Chain_Alphanumeric_Mixed (Chain   : in out Alphanumeric_Mixed;
                                       Success :    out NTSTATUS;
                                       Works   : in out Boolean;
                                       Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in '0' .. '9' | 'A' .. 'Z' | 'a' .. 'z'
                      | '!' | '@' | '#' | '%' | '_' | '-' | '*')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Alphanumeric_Simple is String
     with Dynamic_Predicate =>
       (for all Simple in Alphanumeric_Simple'Range =>
          Alphanumeric_Simple (Simple)
              in '0' .. '9' | 'A' .. 'Z' | 'a' .. 'z');

   procedure Chain_Alphanumeric (Chain   : in out Alphanumeric_Simple;
                                 Success :    out NTSTATUS;
                                 Works   : in out Boolean;
                                 Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in '0' .. '9' | 'A' .. 'Z' | 'a' .. 'z')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Only_Numbers is String
     with Dynamic_Predicate =>
       (for all Simple in Only_Numbers'Range =>
          Only_Numbers (Simple) in '0' .. '9');

   procedure Chain_Only_Numbers (Chain   : in out Only_Numbers;
                                 Success :    out NTSTATUS;
                                 Works   : in out Boolean;
                                 Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in '0' .. '9')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Only_Uppercase is String
     with Dynamic_Predicate =>
       (for all Simple in Only_Uppercase'Range =>
          Only_Uppercase (Simple) in 'A' .. 'Z');

   procedure Chain_Only_Uppercase (Chain   : in out Only_Uppercase;
                                   Success :    out NTSTATUS;
                                   Works   : in out Boolean;
                                   Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range => Chain (Char) in 'A' .. 'Z')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Only_Lowercase is String
     with Dynamic_Predicate =>
       (for all Simple in Only_Lowercase'Range =>
          Only_Lowercase (Simple) in 'a' .. 'z');

   procedure Chain_Only_Lowercase (Chain   : in out Only_Lowercase;
                                   Success :    out NTSTATUS;
                                   Works   : in out Boolean;
                                   Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range => Chain (Char) in 'a' .. 'z')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Only_Letters is String
     with Dynamic_Predicate =>
       (for all Simple in Only_Letters'Range =>
          Only_Letters (Simple) in 'A' .. 'Z' | 'a' .. 'z');

   procedure Chain_Only_Letters (Chain   : in out Only_Letters;
                                 Success :    out NTSTATUS;
                                 Works   : in out Boolean;
                                 Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in 'A' .. 'Z' | 'a' .. 'z')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Only_Symbols is String
     with Dynamic_Predicate =>
       (for all Simple in Only_Symbols'Range =>
          Only_Symbols (Simple) in '!' | '@' | '#' | '%' | '_' | '*' | '-');

   procedure Chain_Only_Symbols (Chain   : in out Only_Symbols;
                                 Success :    out NTSTATUS;
                                 Works   : in out Boolean;
                                 Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in '!' | '@' | '#'
                      | '%' | '_' | '*' | '-')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Only_N_U is String
     with Dynamic_Predicate =>
       (for all Simple in Only_N_U'Range =>
          Only_N_U (Simple) in 'A' .. 'Z' | '0' .. '9');

   procedure Chain_Number_Uppercase (Chain   : in out Only_N_U;
                                     Success :    out NTSTATUS;
                                     Works   : in out Boolean;
                                     Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in 'A' .. 'Z' | '0' .. '9')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Only_N_L is String
     with Dynamic_Predicate =>
       (for all Simple in Only_N_L'Range =>
          Only_N_L (Simple) in 'a' .. 'z' | '0' .. '9');

   procedure Chain_Number_Lowercase (Chain   : in out Only_N_L;
                                     Success :    out NTSTATUS;
                                     Works   : in out Boolean;
                                     Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in 'a' .. 'z' | '0' .. '9')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Hex_Lowercase is String
     with Dynamic_Predicate =>
       (for all Simple in Hex_Lowercase'Range =>
          Hex_Lowercase (Simple) in 'a' .. 'f' | '0' .. '9');

   procedure Chain_Hex_Lowercase (Chain   : in out Hex_Lowercase;
                                  Success :    out NTSTATUS;
                                  Works   : in out Boolean;
                                  Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in 'a' .. 'f' | '0' .. '9')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Hex_Uppercase is String
     with Dynamic_Predicate =>
       (for all Simple in Hex_Uppercase'Range =>
          Hex_Uppercase (Simple) in 'A' .. 'F' | '0' .. '9');

   procedure Chain_Hex_Uppercase (Chain   : in out Hex_Uppercase;
                                  Success :    out NTSTATUS;
                                  Works   : in out Boolean;
                                  Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in 'A' .. 'F' | '0' .. '9')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Compact_Industrial is String
     with Dynamic_Predicate =>
       (for all Simple in Compact_Industrial'Range =>
          Compact_Industrial (Simple) in '0' .. '9' | 'A' .. 'Z'
              | '!' | '.' | '_' | '-' | '*' | '+' | '=' | '~');

   procedure Chain_Compact_Industrial (Chain   : in out Compact_Industrial;
                                       Success :    out NTSTATUS;
                                       Works   : in out Boolean;
                                       Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in '0' .. '9' | 'A' .. 'Z'
                      | '!' | '.' | '_' | '-' | '*' | '+' | '=' | '~')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Human_Readable is String
     with Dynamic_Predicate =>
       (for all Char in Human_Readable'Range =>
          Human_Readable (Char) in '1' .. '9' | 'A' .. 'H' | 'J' .. 'N'
              | 'P' .. 'Z' | 'a' .. 'k' | 'm' .. 'z');

   procedure Chain_Human_Readable (Chain   : in out Human_Readable;
                                   Success :    out NTSTATUS;
                                   Works   : in out Boolean;
                                   Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in '1' .. '9' | 'A' .. 'H' | 'J' .. 'N'
                      | 'P' .. 'Z' | 'a' .. 'k' | 'm' .. 'z')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);

   ----------------------------------------------------------------------------

   subtype Safe_Token is String
     with Dynamic_Predicate =>
       (for all Simple in Safe_Token'Range =>
          Safe_Token (Simple) in '0' .. '9' | 'A' .. 'Z'
              | 'a' .. 'z' | '_' | '-');

   procedure Chain_Safe_Token (Chain   : in out Safe_Token;
                               Success :    out NTSTATUS;
                               Works   : in out Boolean;
                               Entropy : in out sub_entropy)
     with Global => (Input => Ada.Real_Time.Clock_Time),
     Depends => (Chain   => Chain,
                 Success => Chain,
                 Works   =>+ Chain,
                 Entropy =>+ Chain,
                 null => Ada.Real_Time.Clock_Time),
     Pre     => (Chain'Length >= 1) and then (Chain'First = 1)
     and then (Chain'Last = Chain'Length) and then (Chain'Length <= 10_000)
     and then (for all Char in Chain'Range => Chain (Char) = '0')
     and then Works = False
     and then (Entropy = 0.0),
     Post    => (if Works then
                   (for all Char in Chain'Range =>
                        Chain (Char) in '0' .. '9' | 'A' .. 'Z'
                      | 'a' .. 'z' | '_' | '-')
                     else
                   (for all Char in Chain'Range =>
                        Chain (Char) = Chain'Old (Char))
                 and then Entropy = Entropy'Old);
private

   subtype Need_Function is Positive range 250 .. 10000;
   subtype Need_1        is Positive range 250 .. 250;
   subtype Need_2        is Positive range 500 .. 500;
   subtype Need_3        is Positive range 1000 .. 1000;
   subtype Need_4        is Positive range 2000 .. 2000;
   subtype Need_5        is Positive range 3000 .. 3000;
   subtype Need_6        is Positive range 5000 .. 5000;
   subtype Need_7        is Positive range 10000 .. 10000;
   subtype Array_Len_Byt is Positive range 250 .. 15_000;

   R_1 : constant Need_1 := 250;
   R_2 : constant Need_2 := 500;
   R_3 : constant Need_3 := 1000;
   R_4 : constant Need_4 := 2000;
   R_5 : constant Need_5 := 3000;
   R_6 : constant Need_6 := 5000;
   R_7 : constant Need_7 := 10000;

   function Dynamic_Length (Len : Positive) return Need_Function
     with Global => null,
     Pre => (Len >= 1) and then (Len <= Positive'Last),
     Post => (case Len is
                when 1 .. 500 => Dynamic_Length'Result = R_1,
                  when 501 .. 1000 => Dynamic_Length'Result = R_2,
                    when 1001 .. 2500 => Dynamic_Length'Result = R_3,
                      when 2501 .. 5000 => Dynamic_Length'Result = R_4,
                        when 5001 .. 7500 => Dynamic_Length'Result = R_5,
                          when 7501 .. 10000 => Dynamic_Length'Result = R_6,
                            when others => Dynamic_Length'Result = R_7);

   procedure Calculate_Shannon_Entropy (Item : String;
                                        Ento : in out sub_entropy)
     with
       Global  => null,
       Depends => (Ento =>+ Item),
       Pre     => (Item'First = 1)
       and then (Item'Length >= 1)
       and then (Item'Length <= 1_000_000)
       and then (Item'Last = Item'Length)
       and then (Ento = 0.0),
       Post  => Ento in 0.0 .. 8.0;

end Chain_Generator;
