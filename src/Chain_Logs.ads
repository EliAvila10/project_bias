with Interfaces;

package Chain_Logs is

   subtype Bias is Interfaces.Unsigned_8 range 128 .. 255;

   subtype Large_Counter is Long_Long_Integer range
     0 .. Long_Long_Integer'Last;
   type Character_Counter is array (Interfaces.Unsigned_8) of Large_Counter;

   subtype Charsets_Use is String (1 .. 70)
     with Dynamic_Predicate => (for all M in
                                  Charsets_Use'Range =>
                                    Charsets_Use (M) in ' ' .. '~');

   procedure Repetition (Charset  : Charsets_Use;
                         Unbias   : Bias;
                         TotalB   : Large_Counter;
                         Counter  : Character_Counter;
                         RealTime : Duration);

private

   Header_Lines : constant String := "=========================================================================================================================================================================================";
   Left_Line    : constant String := "=== = = = = = = = = = = = = = = = = = = = = = = = = = = = = ";
   Rigth_Line   : constant String := " = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ===";
   Space_Line   : constant String := "-------------------------------------------------------------------------------------------";

   New_Date     : constant String := "Date : ";
   New_Day      : constant String := "| Day : ";
   New_Hour     : constant String := "| Hour : ";

   Charsets     : constant String := "Charset                    => ";
   C_Length     : constant String := "Charset'Length             =>";

   Is_Char      : constant String := "Character => '";
   Is_Appear    : constant String := "' Appear   =>";
   Is_Time      : constant String := " times";

   Mx_Char      : constant String := "Max Repeats               => Character '";
   Mn_Char      : constant String := "Min Repeats               => Character '";
   Mo_Char      : constant String := "' =>";

   Char_Freq    : constant String := "--- Character Frequency [ Total Chars";
   Char_Freq_2  : constant String := " ] ---";

   Divergence_Delta   : constant String := "Divergence Variance Delta =>";
   Ideal_Average      : constant String := "Theoretical Ideal Average => ";
   Standard_Deviation : constant String := "Real Standard Deviation   => ";
   Deviation_Percent  : constant String := "Percet Deviation          => ";
   Time_Duration      : constant String := "Real Time Duration        => ";
   Process_Mbs        : constant String := "Process MB/s              => ";
   Free_Unbis         : constant String := "Free Unbiased Range       => 0 ..";
   Unused_Bts         : constant String := "Unused Bytes              =>";
   Percent_Reject     : constant String := "Reject Percent            => ";
   Unbis_Form         : constant String := "Free Unbiased Formula     => Charset'Length * (256 / Charset'Length) - 1";
   Dist_Stabi         : constant String := "Distribution Stability    => ";

   Ent_Source   : constant String := "Entropy Source            => ProcessPrng (Principal) - BcryptGenRandom (Secondary)";
   Ent_Default  : constant String := "Entropy Default           => ProcessPrng";
   Ent_Fallback : constant String := "Entropy Fallback          => BcryptGenRandom";

end Chain_Logs;
