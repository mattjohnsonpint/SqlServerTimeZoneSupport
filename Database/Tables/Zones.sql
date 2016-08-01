CREATE TABLE [Tzdb].[Zones]
(
    [Id] INT NOT NULL IDENTITY(1,1), 
    [Name] VARCHAR(50) NOT NULL,
    CONSTRAINT [PK_Zones] PRIMARY KEY([Id])
)

GO

CREATE UNIQUE INDEX [IX_Zones_Name] ON [Tzdb].[Zones] ([Name])
