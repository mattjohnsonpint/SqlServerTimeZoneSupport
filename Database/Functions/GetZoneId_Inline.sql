CREATE FUNCTION [Tzdb].GetZoneId_Inline
(
	@tz VARCHAR(50)
) 
RETURNS TABLE WITH SCHEMABINDING AS 
RETURN (
	SELECT ISNULL(l.CanonicalZoneId, z.Id) AS ZoneId
	FROM Tzdb.Zones z LEFT JOIN Tzdb.Links l ON l.LinkZoneId = z.Id
	WHERE z.Name = @tz
)
