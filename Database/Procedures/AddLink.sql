CREATE PROCEDURE [Tzdb].[AddLink]
	@LinkZoneId int,
	@CanonicalZoneId int
AS
DECLARE @cid int
SELECT @cid = @CanonicalZoneId FROM [Tzdb].[Links] WHERE [LinkZoneId] = @LinkZoneId
IF @cid is null
	INSERT INTO [Tzdb].[Links] ([LinkZoneId], [CanonicalZoneId]) VALUES (@LinkZoneId, @CanonicalZoneId)
ELSE IF @cid <> @CanonicalZoneId
	UPDATE [Tzdb].[Links] SET [CanonicalZoneId] = @CanonicalZoneId WHERE [LinkZoneId] = @LinkZoneId
