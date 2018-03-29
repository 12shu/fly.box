/*
	Fly.Box-2.2.1 ������ Fly.Box-2.2.2

	2015-4-22 �Ѱ���
*/


SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Dropping extended properties'
GO
EXEC sp_dropextendedproperty N'MS_Description', 'SCHEMA', N'dbo', 'TABLE', N'fEdu_Class', 'COLUMN', N'HeadTeacher'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[fEdu_ClassStudent]'
GO
ALTER TABLE [dbo].[fEdu_ClassStudent] DROP CONSTRAINT[FK_fEdu_ClassStudent_fEdu_Term]
ALTER TABLE [dbo].[fEdu_ClassStudent] DROP CONSTRAINT[FK_fEdu_ClassStudent_fEdu_Class]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[fEdu_ClassStudent]'
GO
ALTER TABLE [dbo].[fEdu_ClassStudent] DROP CONSTRAINT [�༶��ѧ�ų����ظ�]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fBox_CompareACLVal]'
GO


CREATE TABLE [dbo].[fly_KeyValue](
	[Key] [varchar](100) COLLATE Chinese_PRC_CI_AS NOT NULL,
	[Value] [varchar](max) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]

GO


-- =============================================
-- Author:		�Ѱ���
-- Create date: 2015-4-21 
-- Description:	�Ա�Ȩ��
-- =============================================
CREATE FUNCTION [dbo].[fBox_CompareACLVal]
(
	@all INT,
	@val int
)
RETURNS BIT
AS
BEGIN
	IF(@val=-34) BEGIN	--Open Or Download
		IF (@all & 2)=2 OR (@all & 32)=32
			RETURN 1
		ELSE
			RETURN 0
	END

	IF (@all & @val)=@val
		RETURN 1
	RETURN 0
END




GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fBox_FileBaseACL]'
GO


-- =============================================
-- Author:		�Ѱ���
-- Create date: 2014-6-24 
-- Description:	�ļ�����Ȩ�ޣ����ԣ�
-- =============================================
ALTER FUNCTION [dbo].[fBox_FileBaseACL]
()
RETURNS INT
AS
BEGIN
	--��ӦSpaceFileServiceBase.BaseOrgSpaceFileACL
	--(FileACL.Comment | FileACL.Download | FileACL.Score)
	RETURN 354;
END

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fBox_FileFullACL]'
GO


-- =============================================
-- Author:		�Ѱ���
-- Create date: 2014-6-24 
-- Description:	�ļ�����Ȩ�ޣ����ԣ�
-- =============================================
ALTER FUNCTION [dbo].[fBox_FileFullACL]
()
RETURNS INT
AS
BEGIN
	--��ӦSpaceFileServiceBase.FullOrgSpaceFileACL����
	--(FileACL.Manage | FileACL.Comment | FileACL.Download | FileACL.CreateDir | FileACL.Score | FileACL.Upload)
	RETURN 375;
END

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fBox_CheckSpaceFileUserACL]'
GO




-- =============================================
-- Author:		�Ѱ���
-- Create date: 2014-6-24 
-- Description:	����û��ļ�Ȩ��
-- ����ֵ ���Ƿ���Ȩ��
-- =============================================
ALTER FUNCTION [dbo].[fBox_CheckSpaceFileUserACL]
(
	@spaceFileId VARCHAR(36),
	@userId	VARCHAR(36),
	@checkAcl INT
)
RETURNS BIT
AS
BEGIN
/*
declare @spaceFileId VARCHAR(36)
declare 	@userId	VARCHAR(36)
set @spaceFileId='d0416eb3-3205-4d00-a343-be7a4009ad01'
set @userId='20000000-0000-0000-0000-000000000001'
select dbo.[fBox_CheckSpaceFileUserACL]('d0bb57d1-0fc8-4e6b-b3aa-1a1453291cc9','20000000-0000-0000-0000-000000000001',2)
*/

	DECLARE @acl INT 
	
	--������Լ����ļ���������Ȩ��
	IF(EXISTS(SELECT 1 FROM fBox_SpaceFile WHERE Id=@spaceFileId AND UserId=@userId))
		RETURN 1
	
	SELECT TOP 1 @acl=ACL 
	FROM fBox_SpaceFileUserAuth a 
		JOIN fBox_GetFileParents(@spaceFileId,1) pf
		ON a.SpaceFileId=pf.Id
		WHERE a.UserId=@userId 
	
	--SELECT @acl
	--����������û�Ȩ�ޣ����ü�ⲿ�ź��û���Ȩ��	
	IF(@acl IS NOT NULL) BEGIN
		RETURN dbo.[fBox_CompareACLVal](@acl,@checkAcl)
	END
	
	SET @acl=null;

	--��������˲���Ȩ�ޣ��ҽ�ֹ�����ü������
	SELECT TOP 1 @acl=ACL FROM fBox_SpaceFileDepartmentAuth a 
		JOIN fBox_GetFileParents(@spaceFileId,1) pf
		ON a.SpaceFileId=pf.Id
		WHERE a.DepartmentId=(SELECT DepartmentId FROM dbo.fly_User u WHERE u.Id=@userId)

	IF (@acl IS NOT NULL AND dbo.[fBox_CompareACLVal](@acl,@checkAcl)=0) BEGIN
		RETURN 0;
	END


	--���������һ����ɫ��Ȩ�ޣ�����Ȩ��
	IF(EXISTS(
		SELECT TOP 1 ACL FROM (
			SELECT ACL=(
					CASE WHEN ACL IS NULL THEN 
						CASE WHEN (SELECT TOP 1 IsManager FROM fly_Role WHERE Id=ra.RoleId)=1 
							THEN dbo.fBox_FileFullACL()
						ELSE 
							dbo.fBox_FileBaseACL() 
						END
					ELSE ACL END)
				FROM(
					SELECT 
					RoleId,
					ACL=(SELECT TOP 1 ACL FROM fBox_SpaceFileRoleAuth a 
						JOIN fBox_GetFileParents(@spaceFileId,1) pf
						ON a.SpaceFileId=pf.Id
						WHERE a.RoleId=ur.RoleId)
					FROM fly_UserRole ur WHERE UserId=@userId
				) ra
		)ra2
		WHERE dbo.[fBox_CompareACLVal](ACL,@checkAcl)=1
	))
		RETURN 1
	ELSE
		RETURN 0



	RETURN 0
END




GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fEdu_ClassStudent]'
GO
ALTER TABLE [dbo].[fEdu_ClassStudent] ADD
[IgnoreResult] [bit] NOT NULL CONSTRAINT [DF_fEdu_ClassStudent_IgnoreResult] DEFAULT ((0))
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [һ���༶��ѧ�Ų����ظ�] on [dbo].[fEdu_ClassStudent]'
GO
ALTER TABLE [dbo].[fEdu_ClassStudent] ADD CONSTRAINT [һ���༶��ѧ�Ų����ظ�] PRIMARY KEY CLUSTERED  ([TermId], [ClassId], [NOInClass])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fEdu_Class]'
GO
ALTER TABLE [dbo].[fEdu_Class] DROP
COLUMN [HeadTeacher]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
ALTER TABLE [dbo].[fEdu_Class] ADD [HeadTeacherId] [nvarchar](50) COLLATE Chinese_PRC_CI_AS NOT NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding constraints to [dbo].[fEdu_Class]'
GO
ALTER TABLE [dbo].[fEdu_Class] ADD CONSTRAINT [DF_fEdu_Class_HeadTeacherId] DEFAULT ('') FOR [HeadTeacherId]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[fEdu_ClassStudent]'
GO
ALTER TABLE [dbo].[fEdu_ClassStudent] ADD CONSTRAINT [FK_fEdu_ClassStudent_fEdu_Term] FOREIGN KEY ([TermId]) REFERENCES [dbo].[fEdu_Term] ([Id])
ALTER TABLE [dbo].[fEdu_ClassStudent] ADD CONSTRAINT [FK_fEdu_ClassStudent_fEdu_Class] FOREIGN KEY ([ClassId]) REFERENCES [dbo].[fEdu_Class] ([Id])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating extended properties'
GO
EXEC sp_addextendedproperty N'MS_Description', N'������', 'SCHEMA', N'dbo', 'TABLE', N'fEdu_Class', 'COLUMN', N'HeadTeacherId'
GO

DELETE [fBox_SpaceFileAuths] ;
GO

INSERT INTO [dbo].[fBox_SpaceFileAuths] VALUES (N'1', N'Manage', N'����');
GO
INSERT INTO [dbo].[fBox_SpaceFileAuths] VALUES (N'2', N'Open', N'���');
GO
INSERT INTO [dbo].[fBox_SpaceFileAuths] VALUES (N'4', N'CreateDir', N'�����ļ���');
GO
INSERT INTO [dbo].[fBox_SpaceFileAuths] VALUES (N'16', N'Upload', N'�ϴ�');
GO
INSERT INTO [dbo].[fBox_SpaceFileAuths] VALUES (N'32', N'Download', N'����');
GO
INSERT INTO [dbo].[fBox_SpaceFileAuths] VALUES (N'64', N'Comment', N'����');
GO
INSERT INTO [dbo].[fBox_SpaceFileAuths] VALUES (N'256', N'Score', N'����');
GO




PRINT N'Dropping [dbo].[fBox_CheckSpaceFileUserACL]'
GO
DROP FUNCTION [dbo].[fBox_CheckSpaceFileUserACL]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fBox_CheckSpaceFileUserACL]'
GO

-- =============================================
-- Author:		�Ѱ���
-- Create date: 2014-6-24 
-- Description:	����û��ļ�Ȩ��
-- ����ֵ ���Ƿ���Ȩ��
-- =============================================
CREATE FUNCTION [dbo].[fBox_CheckSpaceFileUserACL]
(
	@spaceFileId VARCHAR(36),
	@userId	VARCHAR(36),
	@checkAcl INT
)
RETURNS BIT
AS
BEGIN
/*
declare @spaceFileId VARCHAR(36)
declare 	@userId	VARCHAR(36)
set @spaceFileId='d0416eb3-3205-4d00-a343-be7a4009ad01'
set @userId='20000000-0000-0000-0000-000000000001'
select dbo.[fBox_CheckSpaceFileUserACL]('d0bb57d1-0fc8-4e6b-b3aa-1a1453291cc9','20000000-0000-0000-0000-000000000001',2)
*/
	--Open Or Download
	if(@checkAcl=-34) BEGIN
		if(dbo.[fBox_CheckSpaceFileUserACL](@spaceFileId,@userId,2)=1)
			return 1
		if(dbo.[fBox_CheckSpaceFileUserACL](@spaceFileId,@userId,32)=1)
			return 1
		return 0;
	END

	DECLARE @acl INT 
	
	--������Լ����ļ���������Ȩ��
	IF(EXISTS(SELECT 1 FROM fBox_SpaceFile WHERE Id=@spaceFileId AND UserId=@userId))
		RETURN 1
	
	SELECT TOP 1 @acl=ACL 
	FROM fBox_SpaceFileUserAuth a 
		JOIN fBox_GetFileParents(@spaceFileId,1) pf
		ON a.SpaceFileId=pf.Id
		WHERE a.UserId=@userId 
	
	--SELECT @acl
	--����������û�Ȩ�ޣ����ü�ⲿ�ź��û���Ȩ��	
	IF(@acl IS NOT NULL) BEGIN
		RETURN dbo.[fBox_CompareACLVal](@acl,@checkAcl)
	END
	
	SET @acl=null;

	--��������˲���Ȩ�ޣ��ҽ�ֹ�����ü������
	SELECT TOP 1 @acl=ACL FROM fBox_SpaceFileDepartmentAuth a 
		JOIN fBox_GetFileParents(@spaceFileId,1) pf
		ON a.SpaceFileId=pf.Id
		WHERE a.DepartmentId=(SELECT DepartmentId FROM dbo.fly_User u WHERE u.Id=@userId)

	IF (@acl IS NOT NULL AND dbo.[fBox_CompareACLVal](@acl,@checkAcl)=0) BEGIN
		RETURN 0;
	END


	--���������һ����ɫ��Ȩ�ޣ�����Ȩ��
	IF(EXISTS(
		SELECT TOP 1 ACL FROM (
			SELECT ACL=(
					CASE WHEN ACL IS NULL THEN 
						CASE WHEN (SELECT TOP 1 IsManager FROM fly_Role WHERE Id=ra.RoleId)=1 
							THEN dbo.fBox_FileFullACL()
						ELSE 
							dbo.fBox_FileBaseACL() 
						END
					ELSE ACL END)
				FROM(
					SELECT 
					RoleId,
					ACL=(SELECT TOP 1 ACL FROM fBox_SpaceFileRoleAuth a 
						JOIN fBox_GetFileParents(@spaceFileId,1) pf
						ON a.SpaceFileId=pf.Id
						WHERE a.RoleId=ur.RoleId)
					FROM fly_UserRole ur WHERE UserId=@userId
				) ra
		)ra2
		WHERE dbo.[fBox_CompareACLVal](ACL,@checkAcl)=1
	))
		RETURN 1
	ELSE
		RETURN 0



	RETURN 0
END


GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fBox_Shortcuts]'
GO
ALTER TABLE [dbo].[fBox_Shortcuts] ADD
[Remark] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fly_KeyValue]'
GO
ALTER TABLE [dbo].[fly_KeyValue] ADD
[Id] [bigint] NOT NULL IDENTITY(1, 1)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fly_KeyValue] on [dbo].[fly_KeyValue]'
GO
CREATE CLUSTERED INDEX [IX_fly_KeyValue] ON [dbo].[fly_KeyValue] ([Key])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_fly_KeyValue] on [dbo].[fly_KeyValue]'
GO
ALTER TABLE [dbo].[fly_KeyValue] ADD CONSTRAINT [PK_fly_KeyValue] PRIMARY KEY NONCLUSTERED  ([Id])



IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO