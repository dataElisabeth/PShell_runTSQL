
IF NOT EXISTS 
(
SELECT * FROM sysobjects WHERE name= 'resAgentJobsList' and xtype='U'
)


CREATE TABLE [dbo].[resAgentJobsList](
	[instance] [sysname] NULL,
	[name] [sysname] NOT NULL,
	[LastRun] [datetime] NULL,
	[minStepDuration] [varchar](92) NULL,
	[maxStepDuration] [varchar](92) NULL,
	[Status] [varchar](11) NULL,
	[NumberOfFailedSteps] [int] NULL,
	[Job last run date] [int] NOT NULL,
	[job last run time] [int] NOT NULL,
	[Job Enabled] [tinyint] NOT NULL,
	[checkDate] [datetime] DEFAULT (getdate())
) ON [PRIMARY];
