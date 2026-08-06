package body Math_Functions with SPARK_Mode => On is

   function Byte_Division (Div : Byte_Length) return Byte_Length is
     (max_byte / Div);

   function Unbiased_Secure (Len : Byte_Length) return Sesgo_Free is
     (Sesgo_Free (Len * Byte_Division (Div => Len) - 1));

   function reject (Vod : Sesgo_Free) return Noused is
     (Noused (max_byte - Vod));

   function Percent (Trh : Noused) return PerRecjt is
     (PerRecjt (Float'Min (50.00, Float'Max
      (0.39, (Float (Trh) / Float (max_byte)) * 100.0))));

end Math_Functions;
