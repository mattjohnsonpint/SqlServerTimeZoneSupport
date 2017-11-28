CREATE FUNCTION [Tzdb].[ToDateTimeOffset_Inline]
(
    @time DATETIME2,
    @tz VARCHAR(50)
)
RETURNS TABLE
WITH SCHEMABINDING
AS RETURN
  SELECT TOP 1
         TODATETIMEOFFSET(@time, ntrvl.[OffsetMinutes])
         AS [Time]
  FROM   [Tzdb].[Intervals] ntrvl
  WHERE  ntrvl.[ZoneId] = (SELECT zn.[ZoneId] FROM [Tzdb].[GetZoneId_Inline](@tz) zn)
  AND    ntrvl.[LocalStart] <= @time
  AND    ntrvl.[LocalEnd] > @time;
GO
