CREATE FUNCTION [Tzdb].[GetZoneAbbreviation]
(
    @dto datetimeoffset,
    @tz varchar(50)
)
RETURNS varchar(10)
AS
BEGIN
    DECLARE @utc datetime2
    SET @utc = CONVERT(datetime2, SWITCHOFFSET(@dto, 0))

    DECLARE @ZoneId int
    SET @ZoneId = [Tzdb].GetZoneId(@tz)

    DECLARE @Abbreviation varchar(10)
    SELECT TOP 1 @Abbreviation = [Abbreviation]
    FROM [Tzdb].[Intervals]
    WHERE [ZoneId] = @ZoneId
      AND [UtcStart] <= @utc AND [UtcEnd] > @utc

    RETURN @Abbreviation
END
