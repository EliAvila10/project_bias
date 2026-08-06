package Math_Functions with SPARK_Mode => On is

   subtype mxb is Positive range 256 .. 256;
   max_byte : constant mxb := 256;

   subtype Byte_Length is Positive range 1 .. 256;
   subtype Sesgo_Free  is Positive range 128 .. 255;
   subtype Noused      is Positive range 1 .. 128;
   subtype PerRecjt    is Float    range 0.39 .. 50.00;

   function Byte_Division (Div : Byte_Length) return Byte_Length
     with
       Global => null,
       Post   => Byte_Division'Result = Byte_Length (max_byte / Div);

   --------

   function Unbiased_Secure (Len : Byte_Length) return Sesgo_Free
     with
       Global => null,
       Post   => Unbiased_Secure'Result =
         Sesgo_Free (Len * Byte_Division (Div => Len) - 1);

   --------

   function Reject (Vod : Sesgo_Free) return Noused
     with
       Global => null,
       Post   => Reject'Result = Noused (max_byte - Vod);

   --------

   function Percent (Trh : Noused) return PerRecjt
     with
       Global => null,
       Post   =>
         Percent'Result = PerRecjt (Float'Min (50.00, Float'Max (0.39,
                                   (Float (Trh) / Float (max_byte)) * 100.0)));

end Math_Functions;
