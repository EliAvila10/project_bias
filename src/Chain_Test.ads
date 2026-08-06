with Ada.Real_Time;
with Interfaces;
with Chain_Logs; -- NO SPARK, Comment Line to verify

package Chain_Test with SPARK_Mode => On is

   use Ada.Real_Time;
   use Chain_Logs; -- NO SPARK, Comment Line to verify

   subtype Rounds  is Positive range 25 .. Positive'Last;
   subtype Options is Positive range 1 .. 14;

   procedure Chain_Public_Test (Loops  : Rounds;
                                Option : Options)
     with Global => (Input  => Ada.Real_Time.Clock_Time);

private

   --  uncomment All this lines to verify with spark

   --  subtype Bias is Interfaces.Unsigned_8 range 128 .. 255;

   --  subtype Large_Counter  is Long_Long_Integer range
   --  0 .. Long_Long_Integer'Last;

   --  type Character_Counter is array
   --  (Interfaces.Unsigned_8) of Large_Counter;

   --  subtype Charsets_Use is String(1 .. 70)
   --  with Dynamic_Predicate => (for all M in
   --                              Charsets_Use'Range =>
   --                                Charsets_Use(M) in ' ' .. '~');

   procedure Gen_test (Round : Rounds;
                       Chain : Charsets_Use;
                       Sesgo : Bias)
     with Global => (Input   => Ada.Real_Time.Clock_Time),
     Depends => (null => (Round, Sesgo, Chain, Ada.Real_Time.Clock_Time));

end Chain_Test;
