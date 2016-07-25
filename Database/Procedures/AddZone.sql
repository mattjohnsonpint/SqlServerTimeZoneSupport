CREATE PROCEDURE [Tzdb].[AddZone]
    @Name varchar(50)
AS
DECLARE @id uniqueidentifier
SELECT @id = [Id] FROM [Tzdb].[Zones] WHERE [Name] = @Name
IF @id is null
BEGIN
	SELECT @id = CAST(HASHBYTES('MD5', @Name) AS UNIQUEIDENTIFIER)
    INSERT INTO [Tzdb].[Zones] ([Id], [Name]) VALUES (@id, @Name)
END
SELECT @id as [Id]