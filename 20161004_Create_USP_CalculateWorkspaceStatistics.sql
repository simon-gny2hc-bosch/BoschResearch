
/***
 * Copyright © - Robert Bosch Engineering and Business Solutions Ltd.
 * All rights reserved. No part of this program or publication may be
 * reproduced, transcribed, stored in a retrieval system, or translated into
 * any language or computer language, or in any form or by any means,
 * electronic, mechanical, magnetic, optical, chemical, biological or
 * otherwise, without the prior written permission of :
 *
 * Robert Bosch Engineering and Business Solutions Ltd.
 *
 * -------------------------------------------------------
 * Object Name : [SM].[USP_Calculate_Workplace_Statistics]
 * -------------------------------------------------------
 *		Module					:  	SPACE MANAGEMENT SYSTEM
 *		Author					:	Nguyen Trung, Dung
 *		Date					:	Sep 27th, 2016
 *		Function				:	Calculate Workplace Statistics
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 *	CRH No						Date						Modified By							Purpose    
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
 *	
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
 ***/

CREATE PROCEDURE [USP_CalculateWorkspaceStatistics]
	@LocationID INT = 0, -- OR 6520,
	@BuildingID INT = NULL, -- OR 2,
	@FloorID INT = NULL, -- OR 2,
	@UnitID INT = NULL -- OR 1 OR 2
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	/**
	 * Prepares Data-source for PIVOT
	 *
	 * Data-source is the result-set of WorkSpace records
	 * which was queried using the Stored Procedure parameters
	 **/
	DECLARE @SourceQuery AS NVARCHAR(MAX)

	IF @LocationID > 0 BEGIN

		IF @BuildingID IS NOT NULL BEGIN
			IF @BuildingID > 0 BEGIN
					
				IF @FloorID IS NOT NULL BEGIN
					IF @FloorID > 0 BEGIN
							
						IF @UnitID IS NOT NULL BEGIN
							IF @UnitID > 0 BEGIN
								-- @LocationID > 0 AND @BuildingID = 0 AND @FloorID > 0 AND @UnitID > 0
								-- calculate Workspace statistics for a Wing using the given @UnitID
								SELECT @SourceQuery =
									N'SELECT
										U.UnitId AS ItemId, U.UnitName AS Name,
										WS.WorkspaceId, WS.WorkspaceTypeId
									FROM Units U
										LEFT JOIN Workspaces WS ON U.UnitID = WS.UnitID AND WS.IsDeleted = 0
									WHERE U.IsDeleted = 0 AND U.UnitId = ' + CAST(@UnitID AS nvarchar(10))
							END
							ELSE BEGIN
								-- @LocationID > 0 AND @BuildingID = 0 AND @FloorID > 0 AND @UnitID = 0
								-- calculate Workspace statistics for all Wings that has FloorID = @FloorID
								SELECT @SourceQuery =
									N'SELECT
										U.UnitId AS ItemId, U.UnitName AS Name,
										WS.WorkspaceId, WS.WorkspaceTypeId
									FROM Units U
										LEFT JOIN Workspaces WS ON U.UnitID = WS.UnitID AND WS.IsDeleted = 0
									WHERE U.IsDeleted = 0 AND U.FloorID = ' + CAST(@FloorID AS nvarchar(10))
							END
						END
						ELSE BEGIN
							-- @LocationID > 0 AND @BuildingID > 0 AND @FloorID > 0 AND @UnitID IS NULL
							-- calculate Workspace statistics for a Floor using the given @FloorID
							SELECT @SourceQuery =
								N'SELECT
									F.FloorId AS ItemId, F.FloorName AS Name,
									WS.WorkspaceId, WS.WorkspaceTypeId
								FROM Floors F
									LEFT JOIN Units U ON F.FloorId = U.FloorId AND U.IsDeleted = 0
									LEFT JOIN Workspaces WS ON U.UnitId = WS.UnitId AND WS.IsDeleted = 0
								WHERE F.IsDeleted = 0 AND F.FloorId = ' + CAST(@FloorID AS nvarchar(10))
						END
					END
					ELSE BEGIN
						-- @LocationID > 0 AND @SubLocationID > 0 AND @BuildingID = 0 AND @FloorID = 0
						-- calculate Workspace statistics for all Floors that has BuildingID = @BuildingID
						SELECT @SourceQuery =
							N'SELECT
								F.FloorId AS ItemId, F.FloorName AS Name,
								WS.WorkspaceId, WS.WorkspaceTypeId
							FROM Floors F
								LEFT JOIN Units U ON F.FloorId = U.FloorId AND U.IsDeleted = 0
								LEFT JOIN Workspaces WS ON U.UnitId = WS.UnitId AND WS.IsDeleted = 0
							WHERE F.IsDeleted = 0 AND F.BuildingId = ' + CAST(@BuildingID AS nvarchar(10))
					END
				END
				ELSE BEGIN
					-- @LocationID > 0 AND @SubLocationID > 0 AND @BuildingID > 0 AND @FloorID IS NULL
					-- calculate Workspace statistics for a Building using the given @BuildingID
					SELECT @SourceQuery =
						N'SELECT
							B.BuildingID AS ItemId, B.BuildingName AS Name,
							WS.WorkspaceId, WS.WorkspaceTypeId
						FROM Buildings B
							LEFT JOIN Floors F ON B.BuildingId = F.BuildingId AND F.IsDeleted = 0
							LEFT JOIN Units U ON F.FloorId = U.FloorId AND U.IsDeleted = 0
							LEFT JOIN Workspaces WS ON U.UnitId = WS.UnitId AND WS.IsDeleted = 0
						WHERE B.IsDeleted = 0 AND B.BuildingId = ' + CAST(@BuildingID AS nvarchar(10))
				END
			END
			ELSE BEGIN
				-- @LocationID > 0 AND @SubLocationID > 0 AND @BuildingID = 0
				-- calculate Workspace statistics for all Buildings that has SubLocationID = @SubLocationID
				SELECT @SourceQuery =
					N'SELECT
						B.BuildingID AS ItemId, B.BuildingName AS Name,
						WS.WorkspaceId, WS.WorkspaceTypeId
					FROM Buildings B
						LEFT JOIN Floors F ON B.BuildingId = F.BuildingId AND F.IsDeleted = 0
						LEFT JOIN Units U ON F.FloorId = U.FloorId AND U.IsDeleted = 0
						LEFT JOIN Workspaces WS ON U.UnitId = WS.UnitId AND WS.IsDeleted = 0
					WHERE B.IsDeleted = 0 AND B.LocationId = ' + CAST(@LocationID AS nvarchar(10))
			END
		END
		ELSE BEGIN -- @LocationID > 0 AND @BuildingID IS NULL
			-- calculate Workspace statistics for a Location using the given @LocationID
			SELECT @SourceQuery =
				N'SELECT L.LocationId AS ItemId, L.LocationName AS Name,
					WS.WorkspaceId, WS.WorkspaceTypeId
				FROM Locations L
					LEFT JOIN Buildings B ON L.LocationId = B.LocationId AND B.IsDeleted = 0
					LEFT JOIN Floors F ON B.BuildingId = F.BuildingId AND F.IsDeleted = 0
					LEFT JOIN Units U ON F.FloorId = U.FloorId AND U.IsDeleted = 0
					LEFT JOIN Workspaces WS ON U.UnitId = WS.UnitId AND WS.IsDeleted = 0
				WHERE L.IsDeleted = 0 AND L.LocationId = ' + CAST(@LocationID AS nvarchar(10))
		END
	END
	ELSE BEGIN -- @LocationID = 0
		-- calculate Workspace statistics for all Locations
		SELECT @SourceQuery =
			N'SELECT
				L.LocationId AS ItemId, L.LocationName  Name,
				WS.WorkspaceId, WS.WorkspaceTypeId
			FROM Locations L
				LEFT JOIN Buildings B ON L.LocationId = B.LocationId AND B.IsDeleted = 0
				LEFT JOIN Floors F ON B.BuildingId = F.BuildingId AND F.IsDeleted = 0
				LEFT JOIN Units U ON F.FloorId = U.FloorId AND U.IsDeleted = 0
				LEFT JOIN Workspaces WS ON U.UnitId = WS.UnitId AND WS.IsDeleted = 0
			WHERE L.IsDeleted = 0'
	END

	-- [1], [2], [3], [4], [5], [6], [10], [12]
	DECLARE @WorkSpaceTypeIdCols AS NVARCHAR(MAX) 
	SELECT @WorkSpaceTypeIdCols = STUFF(
		(
			SELECT ', ' + QUOTENAME(TypeId)
			FROM WorkspaceTypes
			WHERE IsDeleted = 0
			ORDER BY TypeId
			FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
	--PRINT @WorkSpaceTypeIdCols

	-- [1] AS [Workplace], [2] AS [Lab], [3] AS [DH Cabin], [4] AS [GrM Cabin], [5] AS [Meeting Room], [6] AS [Training Room], [10] AS [Cabin], [12] AS [Cabin 1]
	DECLARE @WorkSpaceTypeIdAsNameCols AS NVARCHAR(MAX)
	SELECT @WorkSpaceTypeIdAsNameCols = STUFF(
	(
		SELECT ', ' + QUOTENAME(TypeId) + ' AS ' + QUOTENAME(LTRIM(RTRIM(TypeName)))
		FROM WorkspaceTypes
		WHERE IsDeleted = 0
		ORDER BY TypeId
		FOR XML PATH(''), TYPE
	).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
	--PRINT @WorkSpaceTypeIdAsNameCols

	/**
	 * Prepares the PIVOT Query
	 **/
	DECLARE @CalculateWorkSpaceStatisticsQuery AS NVARCHAR(MAX)
	SELECT @CalculateWorkSpaceStatisticsQuery =
		N'SELECT
			ItemId, Name, ' + @WorkSpaceTypeIdAsNameCols + '
		FROM (' + @SourceQuery + ') Src
		PIVOT (
			COUNT (WorkspaceId) FOR WorkspaceTypeId IN (' + @WorkSpaceTypeIdCols + ')
		) Pvt'

	EXEC(@CalculateWorkSpaceStatisticsQuery)
	PRINT @CalculateWorkSpaceStatisticsQuery

END
