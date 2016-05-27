CREATE FUNCTION [Tzdb].[GetZoneId]
(
    @tz varchar(50)
)
RETURNS uniqueidentifier
AS
BEGIN
    DECLARE @ZoneId uniqueidentifier

    SELECT TOP 1 @ZoneId = l.[CanonicalZoneId]
    FROM [Tzdb].[Zones] z
    JOIN [Tzdb].[Links] l on z.[Id] = l.[LinkZoneId]
    WHERE z.[Name] = @tz

    IF @ZoneId IS NULL
    SELECT TOP 1 @ZoneId = [Id]
    FROM [Tzdb].[Zones]
    WHERE [Name] = @tz

    RETURN @ZoneId
END
