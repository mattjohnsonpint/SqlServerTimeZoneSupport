CREATE FUNCTION [Tzdb].[SwitchZone]
(
    @dto datetimeoffset,
    @tz varchar(50)
)
RETURNS datetimeoffset
AS
BEGIN
    DECLARE @utc datetime2
    SET @utc = CONVERT(datetime2, SWITCHOFFSET(@dto, 0))
    RETURN [Tzdb].[UtcToLocal](@utc, @tz)
END
