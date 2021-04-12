
IF NOT EXISTS 
(
SELECT * FROM sysobjects WHERE name='logScriptExecution' and xtype='U'
)


CREATE TABLE [dbo].[logScriptExecution](
	[targetServer] [sysname] NOT NULL,
	[Script] [varchar](300) NULL,
	[checkDate] [datetime] DEFAULT (getdate()),
	[Success] [varchar](1000) NULL
) ON [PRIMARY];