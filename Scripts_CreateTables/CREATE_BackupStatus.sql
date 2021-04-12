
IF NOT EXISTS 
(
SELECT * FROM sysobjects WHERE name= 'resBackupStatus' and xtype='U'
)

CREATE TABLE [dbo].[resBackupStatus](
			[instance] [sysname] NULL,
	[database_name] [sysname] NOT NULL,
	[recovery_model_desc] [nvarchar](60) NULL,
	[last_log_backup_date] [datetime] NULL,
	[last_diff_backup_date] [datetime] NULL,
	[last_data_backup_date] [datetime] NULL,
	[checkDate] [datetime] DEFAULT (getdate())
) ON [PRIMARY];
