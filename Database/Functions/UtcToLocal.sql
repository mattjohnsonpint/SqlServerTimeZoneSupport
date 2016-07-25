CREATE FUNCTION Tzdb.UtcToLocal
(
    @utc DATETIME2,
    @tz VARCHAR(50)
)
RETURNS DATETIMEOFFSET
WITH SCHEMABINDING AS
BEGIN
    DECLARE @OffsetMinutes INT

    SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
    FROM [Tzdb].[Intervals] i INNER JOIN Tzdb.GetZoneId_Inline(@tz) z ON i.ZoneId = z.ZoneId
    WHERE  [UtcStart] <= @utc AND [UtcEnd] > @utc

    RETURN TODATETIMEOFFSET(DATEADD(MINUTE, @OffsetMinutes, @utc), @OffsetMinutes)
END
