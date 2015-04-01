CREATE TABLE [Tzdb].[Zones]
(
    [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1), 
    [Name] VARCHAR(50) NOT NULL
)

GO

CREATE UNIQUE INDEX [IX_Zones_Name] ON [Tzdb].[Zones] ([Name])
