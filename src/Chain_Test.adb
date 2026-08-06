pragma Suppress_All;     -- comment to verify
pragma Optimize (time);  -- comment to verify

with Windows_Data_Types;
with BcryptGenRandom_Wrapper;
with ProcessPrng_Wrapper;
with Ada.Strings.Fixed;
with Interfaces.C;
with Math_Functions;

package body Chain_Test with SPARK_Mode => On is

   use Windows_Data_Types;
   use BcryptGenRandom_Wrapper;
   use ProcessPrng_Wrapper;
   use Interfaces.C;
   use Math_Functions;
   use Interfaces;

   procedure Chain_Public_Test (Loops  : Rounds;
                                Option : Options)
   is
      type Charsets is array (1 .. 14) of Charsets_Use;
      Charset : constant Charsets :=
        (1  => "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#%_*- " & (71 .. 70 => ' '),
         2  => "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "        & (64 .. 70 => ' '),
         3  => "0123456789 "                                                            & (12 .. 70 => ' '),
         4  => "ABCDEFGHIJKLMNOPQRSTUVWXYZ "                                            & (28 .. 70 => ' '),
         5  => "abcdefghijklmnopqrstuvwxyz "                                            & (28 .. 70 => ' '),
         6  => "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "                  & (54 .. 70 => ' '),
         7  => "!@#%_*- "                                                               & (9  .. 70  => ' '),
         8  => "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ "                                  & (38 .. 70 => ' '),
         9  => "0123456789abcdefghijklmnopqrstuvwxyz "                                  & (38 .. 70 => ' '),
         10 => "0123456789abcdef "                                                      & (18 .. 70 => ' '),
         11 => "0123456789ABCDEF "                                                      & (18 .. 70 => ' '),
         12 => "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!._-*+=~ "                          & (46 .. 70 => ' '),
         13 => "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz "            & (60 .. 70 => ' '),
         14 => "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_ "      & (66 .. 70 => ' '));

      Position : constant Natural range 0 .. Charsets_Use'Length
        := Ada.Strings.Fixed.Index (Charset (Option), " ");

      Len_Max  : constant Boolean  := (Position > 7);

   begin

      if Len_Max then
         Gen_test (Round => Loops,
                  Chain => Charset (Option),
                  Sesgo => Bias (Unbiased_Secure (Len => Position - 1)));
      else
         return;
      end if;

   end Chain_Public_Test;

   --------

   --  BUFFER MAX IN MI PC 3_500_000 BEFORE STACK OVERFLOW

   procedure Gen_test (Round : Rounds;
                       Chain : Charsets_Use;
                       Sesgo : Bias)
   is
      Rnd_Buffer : BUFFER_RNG (0 .. 50_000) := (others => 0);
      subtype Unbiased is Interfaces.Unsigned_8 range 0 .. Sesgo;

      Is_Perfect_RNG : constant Boolean := (Sesgo = 255);
      Success        : NTSTATUS;
      Start          : Ada.Real_Time.Time;
      Finish         : Ada.Real_Time.Time;
      Interval       : Ada.Real_Time.Time_Span;
      T_Duration     : Duration;

      Total_Bytes : Large_Counter := 0;
      B           : Character_Counter := (others => 0);

   begin

      pragma Assert (Rnd_Buffer'Length >= 25_000);

      if Is_Perfect_RNG then

         Start := Ada.Real_Time.Clock;

         Outer_Loop :
         for I in 1 .. Round loop

            pragma Loop_Variant (Increases => I);
            pragma Loop_Invariant (I in 1 .. Round);

            pragma Loop_Invariant
              (for all E in B'Range =>
                 B (E) <= B'Loop_Entry (Outer_Loop)(E)
               + (Large_Counter (I - 1) * Rnd_Buffer'Length));

            Success := NTSTATUS'Last;
            ProcessPrng_Public (Buffer => Rnd_Buffer,
                                Status => Success);

            if Success /= 1 then

               Success := NTSTATUS'Last;
               BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                       Status => Success);

               if Success /= 0 then
                  return;
               end if;

            end if;

            Inner_Loop :
            for Idx in Rnd_Buffer'First .. Rnd_Buffer'Last loop

               pragma Loop_Variant (Increases => Idx);
               pragma Loop_Invariant (Idx in Rnd_Buffer'First
                                      .. Rnd_Buffer'Last);

               pragma Loop_Invariant
                 (for all E in B'Range =>
                    B (E) <= B'Loop_Entry (Outer_Loop)(E)
                  + (Large_Counter (I - 1) * Rnd_Buffer'Length)
                  + Large_Counter (Idx - Rnd_Buffer'First));

               pragma Loop_Invariant (for all E in B'Range => B (E) >= 0);

               B (Rnd_Buffer (Idx)) := B (Rnd_Buffer (Idx)) + 1;

            end loop Inner_Loop;
         end loop Outer_Loop;

         Finish := Ada.Real_Time.Clock;

      else

         Start := Ada.Real_Time.Clock;

         Outer_Loop_2 :
         for I in 1 .. Round loop

            pragma Loop_Variant (Increases => I);
            pragma Loop_Invariant (I in 1 .. Round);

            pragma Loop_Invariant
              (for all E in B'Range =>
                 B (E) <= B'Loop_Entry (Outer_Loop_2)(E)
               + (Large_Counter (I - 1) * Rnd_Buffer'Length));

            Success := NTSTATUS'Last;
            ProcessPrng_Public (Buffer => Rnd_Buffer,
                               Status => Success);

            if Success /= 1 then

               Success := NTSTATUS'Last;
               BcryptGenRandom_Public (Buffer => Rnd_Buffer,
                                      Status => Success);

               if Success /= 0 then
                  return;
               end if;

            end if;

            Inner_Loop_2 :
            for Idx in Rnd_Buffer'First .. Rnd_Buffer'Last loop

               pragma Loop_Variant (Increases => Idx);
               pragma Loop_Invariant
                 (Idx in Rnd_Buffer'First .. Rnd_Buffer'Last);

               pragma Loop_Invariant
                 (for all E in B'Range =>
                    B (E) <= B'Loop_Entry (Outer_Loop_2)(E)
                  + (Large_Counter (I - 1) * Rnd_Buffer'Length)
                  + Large_Counter (Idx - Rnd_Buffer'First));

               pragma Loop_Invariant (for all E in B'Range => B (E) >= 0);

               if Rnd_Buffer (Idx) in Unbiased then
                  B (Rnd_Buffer (Idx)) := B (Rnd_Buffer (Idx)) + 1;
               end if;

            end loop Inner_Loop_2;
         end loop Outer_Loop_2;

         Finish := Ada.Real_Time.Clock;

      end if;

      pragma Assert
        (for all E in B'Range =>
           B (E) <= Large_Counter (Round) * Rnd_Buffer'Length);

      Interval := Finish - Start;
      T_Duration := Ada.Real_Time.To_Duration (TS => Interval);

      Total_Bytes := 0;
      for I in Interfaces.Unsigned_8 range B'First .. Sesgo loop

         pragma Loop_Variant (Increases => I);

         pragma Loop_Invariant (I in B'First .. Sesgo);

         pragma Loop_Invariant
           (Total_Bytes <= Long_Long_Integer (I - B'First)
            * (Long_Long_Integer (Round) * 25001));

         pragma Loop_Invariant
           (for all K in B'First .. Sesgo => B (K)
            <= Long_Long_Integer (Round) * 25001);

         pragma Loop_Invariant (Total_Bytes >= 0);
         pragma Loop_Invariant
           (if I > B'First then Total_Bytes >= Long_Long_Integer (B (B'First)));

         Total_Bytes := Total_Bytes + B (I);
      end loop;

      Chain_Logs.Repetition (Charset  => Chain,       -- Comments Line to
                             Unbias   => Sesgo,       -- To use Spark
                             TotalB   => Total_Bytes, -- to verify
                             Counter  => B,           --
                             RealTime => T_Duration); --
      Total_Bytes := 0;
      pragma Unreferenced (Total_Bytes);
      B := (others => 0);
      pragma Unreferenced (B);
   end Gen_test;

end Chain_Test;
