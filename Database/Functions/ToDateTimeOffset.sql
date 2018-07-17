CREATE FUNCTION [Tzdb].[ToDateTimeOffset]
(
    @time DATETIME2,
    @tz VARCHAR(50)
)
RETURNS DATETIMEOFFSET
BEGIN
	DECLARE @OffsetMinutes INT;

	SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
    FROM [Tzdb].[Intervals] i
	INNER JOIN Tzdb.GetZoneId_Inline(@tz) z ON i.ZoneId = z.ZoneId
    WHERE  LocalStart <= @time AND LocalEnd > @time;

	RETURN TODATETIMEOFFSET(@time, @OffsetMinutes);
END
