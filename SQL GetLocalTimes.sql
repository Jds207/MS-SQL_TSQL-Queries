DECLARE @TimeZone VARCHAR(50)
		,@Offset INT
		,@LocalTime AS DATETIME
		,@LocalTimeZone AS VARCHAR(6)= '-06:00' --CST Timezone
		,@UTCTime DATETIMEOFFSET(7) = GetUTCDate()

	--Set the time zone offset of the timezone you are wanting. 

	--Gets timezone of server
	EXEC MASTER.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
		,'SYSTEM\CurrentControlSet\Control\TimeZoneInformation'
		,'TimeZoneKeyName'
		,@TimeZone OUT

	--Determines timezone offset of the sql server. This is used to determine daylight savings
	SET @Offset = CASE 
			WHEN CHARINDEX('Eastern', @TimeZone) > 0
				THEN 5
			WHEN CHARINDEX('Central', @TimeZone) > 0
				THEN 6
			WHEN CHARINDEX('Mountain', @TimeZone) > 0
				THEN 7
			WHEN CHARINDEX('Pacific', @TimeZone) > 0
				THEN 8
			WHEN CHARINDEX('Alaska', @TimeZone) > 0
				THEN 9
			WHEN CHARINDEX('Hawaii', @TimeZone) > 0
				THEN 10
			ELSE 0
			END
	
	--Set local time
	SET @LocalTime = CONVERT(DATETIME2, Switchoffset(@UTCTime, @LocalTimeZone))

	--Determines if day light savings is in effect
    IF CAST(DATEDIFF(HH, GETDATE(), GETUTCDATE()) AS INT) = (@Offset-1)
	BEGIN
	    --Set local time if day light savings is in effect
		SET @LocalTime = CONVERT(DATETIME2, Switchoffset(@LocalTime, '+01:00'))
	END

	SELECT @LocalTime AS [LocalTime], @UTCTime AS [UTCTime]