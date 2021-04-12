
IF NOT EXISTS 
(
SELECT * FROM sysobjects WHERE name= 'resCHECKDBStatus' and xtype='U'
)

CREATE TABLE [dbo].[resCHECKDBStatus](
	[instance] [sysname] NULL,
	[DatabaseName] [sysname] NULL,
	[dbccLastKnownGood] [varchar](255) NULL,
	[DaysSinceGoodCheckDB] [int] NULL,
	[HoursSinceGoodCheckDB] [int] NULL,
	[checkDate] [datetime] DEFAULT (getdate())
) ON [PRIMARY];

