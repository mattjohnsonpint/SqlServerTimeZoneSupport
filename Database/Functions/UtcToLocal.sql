CREATE FUNCTION [Tzdb].[UtcToLocal]
(
    @utc datetime2,
    @tz varchar(50)
)
RETURNS datetimeoffset
AS
BEGIN
    DECLARE @OffsetMinutes smallint

    DECLARE @ZoneId int
    SET @ZoneId = [Tzdb].GetZoneId(@tz)

    SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
    FROM [Tzdb].[Intervals]
    WHERE [ZoneId] = @ZoneId
      AND [UtcStart] <= @utc AND [UtcEnd] > @utc

    RETURN TODATETIMEOFFSET(DATEADD(MINUTE, @OffsetMinutes, @utc), @OffsetMinutes)
END
