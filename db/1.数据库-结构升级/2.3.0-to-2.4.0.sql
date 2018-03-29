/*
	Fly.Box-2.3.0 ������ Fly.Box-2.4.0

	2016-5-23 ���˿Ƽ�
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
PRINT N'Altering [dbo].[fBox_SpaceFile]'
GO
ALTER TABLE [dbo].[fBox_SpaceFile] ADD
[Path] [varchar] (900) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF_fBox_SpaceFile_Path] DEFAULT ('')
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_SpaceFile Path] on [dbo].[fBox_SpaceFile]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_SpaceFile Path] ON [dbo].[fBox_SpaceFile] ([Path])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_SpaceFile Name] on [dbo].[fBox_SpaceFile]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_SpaceFile Name] ON [dbo].[fBox_SpaceFile] ([Name])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_SpaceFile State] on [dbo].[fBox_SpaceFile]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_SpaceFile State] ON [dbo].[fBox_SpaceFile] ([State])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fBox_BuildFileFullPath]'
GO

-- =============================================
-- Author:		Kuiyou
-- Create date: 2016-5-20 11:00
-- Description:	�����ļ�������·����������Ŀ¼��
-- =============================================
CREATE FUNCTION [dbo].[fBox_BuildFileFullPath]
(
	@spaceFileId VARCHAR(36)
)
RETURNS varchar(900)
AS
BEGIN
	DECLARE @path varchar(900);
	SET @path='';	
	SELECT @path=@path+'/'+Id FROM dbo.fBox_GetFileParents(@spaceFileId,1) ORDER BY Level
	--select @path
	RETURN @path
END



GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[fBox_User]'
GO
EXEC sp_refreshview N'[dbo].[fBox_User]'
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
set @userId='2000000001'
select dbo.[fBox_CheckSpaceFileUserACL]('d0bb57d1-0fc8-4e6b-b3aa-1a1453291cc9','2000000001',2)
*/
	--������Լ���ҵ�ռ���ļ���ֻҪ�ǹ���Ա����Ȩ��
	IF( EXISTS(SELECT * FROM dbo.fBox_OrgSpace os 
		WHERE os.OrgId=(SELECT OrgId FROM dbo.fBox_User u WHERE u.Id=@userId )
			AND os.SpaceId=(SELECT SpaceId FROM dbo.fBox_SpaceFile sf WHERE sf.Id=@spaceFileId))
			AND EXISTS(SELECT * FROM fBox_User u WHERE u.Id=@userId AND u.IsDiskManager=1)
			)
		RETURN 1;
	
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
PRINT N'Creating [dbo].[fBox_CheckSpaceFileUserACL2]'
GO



-- =============================================
-- Author:		�Ѱ���
-- Create date: 2014-6-24 
-- Description:	����û��ļ�Ȩ��
-- ����ֵ ���Ƿ���Ȩ��
-- =============================================
CREATE FUNCTION [dbo].[fBox_CheckSpaceFileUserACL2]
(
	@spaceFileId VARCHAR(36),
	@userId	VARCHAR(36),
	@checkAcl INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT Has= [dbo].[fBox_CheckSpaceFileUserACL](@spaceFileId,@userId,@checkAcl)
)


GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fBox_GetSpaceFileUserACL]'
GO






-- =============================================
-- Author:		�Ѱ���
-- Create date: 2014-6-24 
-- Description:	��ȡ�û��ļ�Ȩ��
-- ����ֵ ���û�Ȩ��
--	û��:��ʾû�������û�Ȩ�ޣ��Ǽ̳в��š��û���Ȩ��
--  :����|��ʾͨ���Լ����ã������ʾͨ���ϼ�����
-- =============================================
ALTER FUNCTION [dbo].[fBox_GetSpaceFileUserACL]
(
	@spaceFileId VARCHAR(36),
	@userId	VARCHAR(36)
)
RETURNS VARCHAR(30)
AS
BEGIN
/*
declare @spaceFileId VARCHAR(36)
declare 	@userId	VARCHAR(36)
set @spaceFileId='d0416eb3-3205-4d00-a343-be7a4009ad01'
set @userId='2000000001'
--select dbo.[fBox_GetSpaceFileUserACL]('d0416eb3-3205-4d00-a343-be7a4009ad01','2000000001')
*/

	DECLARE @acl INT 
	DECLARE @aclStr VARCHAR(30) 
	DECLARE @fullACL INT
	DECLARE @baseACL INT
	

	SELECT TOP 1 @aclStr=
		CAST(ACL AS VARCHAR)+':'+
		(CASE WHEN a.SpaceFileId=@spaceFileId 
			THEN '|'
			ELSE (SELECT Name FROM fBox_SpaceFile sf WHERE sf.Id=a.SpaceFileId) END)
	FROM fBox_SpaceFileUserAuth a 
		JOIN fBox_GetFileParents(@spaceFileId,1) pf
		ON a.SpaceFileId=pf.Id
		WHERE a.UserId=@userId

	--SELECT @acl
	--����������û�Ȩ�ޣ����ü�ⲿ�ź��û���Ȩ��
	IF(@aclStr IS NOT NULL)
		RETURN @aclStr

	SET @fullACL=dbo.fBox_FileFullACL()
	SET @baseACL=dbo.fBox_FileBaseACL()

	SELECT TOP 1 @acl=ACL FROM fBox_SpaceFileDepartmentAuth a 
		JOIN fBox_GetFileParents(@spaceFileId,1) pf
		ON a.SpaceFileId=pf.Id
		WHERE a.DepartmentId=(SELECT DepartmentId FROM dbo.fly_User u WHERE u.Id=@userId)

	--���û�����ò���Ȩ�ޣ���Ĭ�ϲ���������Ȩ��
	IF(@acl IS NULL)
		SET @acl=@fullACL

	--SELECT @acl
	DECLARE @acls TABLE(ACL INT);
	
	INSERT INTO @acls
	SELECT ACL=(
			CASE WHEN ACL IS NULL THEN 
				CASE WHEN (SELECT TOP 1 IsManager FROM fly_Role WHERE Id=ra.RoleId)=1 
					THEN @fullACL 
				ELSE @baseACL END
			ELSE ACL END)-- INTO #acls  
		FROM(
			SELECT 
			--Name=(SELECT Name FROM fly_Role WHERE Id=ur.RoleId),
			ur.RoleId,
			ACL=(SELECT TOP 1 ACL FROM fBox_SpaceFileRoleAuth a 
				JOIN fBox_GetFileParents(@spaceFileId,1) pf
				ON a.SpaceFileId=pf.Id
				WHERE a.RoleId=ur.RoleId)
			FROM fly_UserRole ur WHERE UserId=@userId
		) ra

	--SELECT * FROM #acls
	--���¼���@acl
	--������򣬲���Ȩ�ޱ����У��û���Ȩ��������һ����
	SELECT @acl=SUM(ACL) 
		FROM fBox_SpaceFileAuths auths
		WHERE (@acl & ACL)=ACL AND EXISTS(SELECT 1 FROM @acls a WHERE (a.ACL & auths.ACL)=auths.ACL)

	--SELECT @acl

	RETURN @acl;
END







GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fBox_GetSpaceFileUserACL2]'
GO





-- =============================================
-- Author:		�Ѱ���
-- Create date: 2014-6-24 
-- Description:	��ȡ�û��ļ�Ȩ��
-- ����ֵ ���û�Ȩ��
--	û��:��ʾû�������û�Ȩ�ޣ��Ǽ̳в��š��û���Ȩ��
--  :����|��ʾͨ���Լ����ã������ʾͨ���ϼ�����
-- =============================================
-- =============================================
CREATE FUNCTION [dbo].[fBox_GetSpaceFileUserACL2]
(
	@spaceFileId VARCHAR(36),
	@userId	VARCHAR(36)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT Acl= [dbo].[fBox_GetSpaceFileUserACL](@spaceFileId,@userId)
)




GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fly_im_GetLeaveMsgs]'
GO








-- =============================================
-- Author:		Kuiyou
-- Create date: 2015-6-19
-- Description:	��ѯ�û���������
-- =============================================
ALTER FUNCTION [dbo].[fly_im_GetLeaveMsgs] 
(
	@userId varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
SELECT m.* FROM fly_im_Message m
	LEFT JOIN fly_im_UserSessionInfo us 
	ON us.UserId=@userId AND m.SessionId=us.SessionId

	WHERE m.SessionId IN(
		SELECT Id FROM fly_im_Session s 
			WHERE (Member1=@userId OR Member2=@userId) OR s.GroupId IN(
				SELECT ID FROM dbo.fly_im_GetUserGroupIds(@userId)
			))
		AND (us.LastReadTime<m.Time OR us.LastReadTime IS NULL)
)

--
--select * from dbo.[fly_im_GetLeaveMsgs]('2000000001')
--
--
--declare @userId varchar(36)
--set @userId='2000000001'
--SELECT * FROM fly_im_Message m
--
--	LEFT JOIN fly_im_MessageRead us 
--	ON us.UserId=@userId AND m.SessionId=us.SessionId
--
--	WHERE m.SessionId IN(
--		SELECT Id FROM fly_im_Session s 
--			WHERE (Member1=@userId OR Member2=@userId) OR s.GroupId IN(
--				SELECT ID FROM dbo.fly_im_GetUserGroups(@userId)
--			))
--		AND (us.LastReadTime<m.Time OR us.LastReadTime IS NULL)

			






GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fly_im_GetRecentlySessions]'
GO








-- =============================================
-- Author:		Kuiyou
-- Create date: 2015-6-25
-- Description:	��ѯ����Ự
-- =============================================
ALTER FUNCTION [dbo].[fly_im_GetRecentlySessions] 
(
	@userId varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT * FROM (
		SELECT s.Id,
				(SELECT TOP 1 m.Time FROM fly_im_Message m where m.SessionId = s.Id ) AS [Time],
				s.TargetType,
				Target =CASE WHEN s.GroupId IS NOT NULL THEN s.GroupId WHEN s.Member1 <> @userId THEN s.Member1 ELSE s.Member2 END
				FROM fly_im_Session s
								where ((s.Member1 = @userId OR s.Member2 = @userId) 
										OR EXISTS(SELECT * FROM dbo.fly_im_GetUserGroupIds(@userId) ug WHERE ug.Id = s.GroupId))
		) session 
)

--
--select * from GetRecentlySessions('2000000001')
--
--


--declare @userId varchar(36)
--set @userId='2000000001'
--
--	SELECT * FROM (
--		SELECT s.Id,
--				(SELECT TOP 1 m.Time FROM fly_im_Message m where m.SessionId = s.Id ) AS [Time],
--				s.TargetType,
--				Target =CASE WHEN s.GroupId IS NOT NULL THEN s.GroupId WHEN s.Member1 <> @userId THEN s.Member1 ELSE s.Member2 END
--				FROM fly_im_Session s
--								where ((s.Member1 = @userId OR s.Member2 = @userId) 
--										OR EXISTS(SELECT * FROM dbo.fly_im_GetUserGroups(@userId) ug WHERE ug.Id = s.GroupId))
--		) session 
--		WHERE Time IS NOT NULL 
--		ORDER BY Time DESC



GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fly_im_GetLeaveCounts]'
GO










-- =============================================
-- Author:		Kuiyou
-- Create date: 2015-6-19
-- Description:	��ѯ�û���������
-- =============================================
ALTER FUNCTION [dbo].[fly_im_GetLeaveCounts] 
(
	@userId varchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT s.TargetType,
	   m.SessionId,
		(SELECT CASE 
				WHEN GroupId IS NOT NULL THEN GroupId 
				WHEN Member1 <> @userId THEN Member1 
				ELSE Member2 END
		FROM fly_im_Session session WHERE session.Id= m.SessionId ) AS Target,
		Count(1) AS Count
	FROM fly_im_Message m
	LEFT JOIN fly_im_Session s 
		ON m.SessionId=s.Id
	LEFT JOIN fly_im_UserSessionInfo us 
		ON us.UserId=@userId AND m.SessionId=us.SessionId

	WHERE m.SenderId<>@userId AND ((s.Member1=@userId OR s.Member2=@userId) OR s.GroupId IN(
					SELECT ID FROM dbo.fly_im_GetUserGroupIds(@userId)
				)
			)
		AND (us.LastReadTime<m.Time OR us.LastReadTime IS NULL)
	GROUP BY s.TargetType, m.SessionId 
)

--
--select * from [fly_im_GetLeaveCounts]('2000000001')
--
--
--declare @userId varchar(36)
--set @userId='2000000001'
--
--
--SELECT s.TargetType,
--	   m.SessionId,
--		(SELECT CASE 
--				WHEN GroupId IS NOT NULL THEN GroupId 
--				WHEN Member1 <> @userId THEN Member1 
--				ELSE Member2 END
--		FROM fly_im_Session session WHERE session.Id= m.SessionId ) AS Target,
--		Count(1) AS Count
--	FROM fly_im_Message m
--	LEFT JOIN fly_im_Session s 
--		ON m.SessionId=s.Id
--	LEFT JOIN fly_im_MessageRead mr 
--		ON mr.UserId=@userId AND m.SessionId=mr.SessionId
--
--	WHERE ((s.Member1=@userId OR s.Member2=@userId) OR s.GroupId IN(
--					SELECT ID FROM dbo.fly_im_GetUserGroups(@userId)
--				)
--			)
--		AND (mr.LastReadTime<m.Time OR mr.LastReadTime IS NULL)
--	GROUP BY s.TargetType, m.SessionId 
--
--			








GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fly_im_Group]'
GO
ALTER TABLE [dbo].[fly_im_Group] ADD
[Status] [int] NOT NULL CONSTRAINT [DF_fly_im_Group_Status] DEFAULT ((1))
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[fly_Log]'
GO
ALTER TABLE [dbo].[fly_Log] ALTER COLUMN [Value] [nvarchar] (200) COLLATE Chinese_PRC_CI_AS NULL
ALTER TABLE [dbo].[fly_Log] ALTER COLUMN [Referer] [nvarchar] (500) COLLATE Chinese_PRC_CI_AS NULL
ALTER TABLE [dbo].[fly_Log] ALTER COLUMN [Remark] [nvarchar] (200) COLLATE Chinese_PRC_CI_AS NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [fly_Log_Index_UserId_InfoType_InfoId_Action_NumValue_IsValid] on [dbo].[fly_Log]'
GO
CREATE NONCLUSTERED INDEX [fly_Log_Index_UserId_InfoType_InfoId_Action_NumValue_IsValid] ON [dbo].[fly_Log] ([UserId], [InfoType], [InfoId], [Action], [NumValue], [IsValid])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fBox_FileSend]'
GO
CREATE TABLE [dbo].[fBox_FileSend]
(
[Id] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[UserId] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FileId] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TargetType] [int] NOT NULL,
[Target] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Time] [datetime] NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_fBox_FileSend] on [dbo].[fBox_FileSend]'
GO
ALTER TABLE [dbo].[fBox_FileSend] ADD CONSTRAINT [PK_fBox_FileSend] PRIMARY KEY CLUSTERED  ([Id])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_FileSend UserId] on [dbo].[fBox_FileSend]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_FileSend UserId] ON [dbo].[fBox_FileSend] ([UserId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_FileSend FileId] on [dbo].[fBox_FileSend]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_FileSend FileId] ON [dbo].[fBox_FileSend] ([FileId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_FileSend TargetType,Target] on [dbo].[fBox_FileSend]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_FileSend TargetType,Target] ON [dbo].[fBox_FileSend] ([TargetType], [Target])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_FileSend Time] on [dbo].[fBox_FileSend]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_FileSend Time] ON [dbo].[fBox_FileSend] ([Time])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[fBox_FileReceive]'
GO
CREATE TABLE [dbo].[fBox_FileReceive]
(
[Id] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SendId] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[UserId] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Time] [datetime] NOT NULL,
[Cmd] [int] NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_fBox_FileReceive] on [dbo].[fBox_FileReceive]'
GO
ALTER TABLE [dbo].[fBox_FileReceive] ADD CONSTRAINT [PK_fBox_FileReceive] PRIMARY KEY CLUSTERED  ([Id])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_FileReceive SendId] on [dbo].[fBox_FileReceive]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_FileReceive SendId] ON [dbo].[fBox_FileReceive] ([SendId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_FileReceive UserId] on [dbo].[fBox_FileReceive]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_FileReceive UserId] ON [dbo].[fBox_FileReceive] ([UserId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_FileReceive Time] on [dbo].[fBox_FileReceive]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_FileReceive Time] ON [dbo].[fBox_FileReceive] ([Time])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_Compression CreateUserId] on [dbo].[fBox_Compression]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_Compression CreateUserId] ON [dbo].[fBox_Compression] ([CreateUserId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_ShareFile SpaceFileId] on [dbo].[fBox_ShareFile]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_ShareFile SpaceFileId] ON [dbo].[fBox_ShareFile] ([SpaceFileId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_File MD5] on [dbo].[fBox_File]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_File MD5] ON [dbo].[fBox_File] ([MD5])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_Share ShareUserId] on [dbo].[fBox_Share]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_Share ShareUserId] ON [dbo].[fBox_Share] ([ShareUserId])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [IX_fBox_Share Status] on [dbo].[fBox_Share]'
GO
CREATE NONCLUSTERED INDEX [IX_fBox_Share Status] ON [dbo].[fBox_Share] ([Status])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[fBox_FileReceive]'
GO
ALTER TABLE [dbo].[fBox_FileReceive] ADD CONSTRAINT [FK_fBox_FileReceive_fBox_FileSend] FOREIGN KEY ([SendId]) REFERENCES [dbo].[fBox_FileSend] ([Id])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating extended properties'
GO
EXEC sp_addextendedproperty N'MS_Description', N'���յķ�ʽ��Down/Open/Save/Share��', 'SCHEMA', N'dbo', 'TABLE', N'fBox_FileReceive', 'COLUMN', N'Cmd'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', N'���͵�id', 'SCHEMA', N'dbo', 'TABLE', N'fBox_FileReceive', 'COLUMN', N'SendId'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', N'����ʱ��', 'SCHEMA', N'dbo', 'TABLE', N'fBox_FileReceive', 'COLUMN', N'Time'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', N'���յ��û�id', 'SCHEMA', N'dbo', 'TABLE', N'fBox_FileReceive', 'COLUMN', N'UserId'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_addextendedproperty N'MS_Description', N'������id', 'SCHEMA', N'dbo', 'TABLE', N'fBox_FileSend', 'COLUMN', N'UserId'
GO
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