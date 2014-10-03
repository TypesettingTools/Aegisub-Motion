log = require 'a-mo.Log'

class Transform

	tags = tags or require 'a-mo.Tags'

	-- An alternate constructor.
	@fromString: ( transformString, lineDuration, tagIndex, parentLine ) =>
		transStart, transEnd, transExp, transEffect = transformString\match "%(([%-%d]*),?([%-%d]*),?([%d%.]*),?(.+)%)"
		-- Catch the case of \t(2.345,\1c&H0000FF&), where the 2 gets
		-- matched to transStart and the .345 gets matched to transEnd.
		if tonumber( transStart ) and not tonumber( transEnd )
			transExp = transStart .. transExp
			transStart = ""

		transExp = tonumber( transExp ) or 1
		transStart = tonumber( transStart ) or 0

		transEnd = tonumber( transEnd ) or 0
		if transEnd == 0
			transEnd = lineDuration

		object = @ transStart, transEnd, transExp, transEffect, tagIndex, parentLine
		object.rawString = transformString
		return object

	new: ( @startTime, @endTime, @accel, @effect, @index, @parentLine ) =>

	toString: ( line = @parentLine ) =>
		if @effect == ""
			return ""
		elseif @endTime <= 0
			line.transformEnded = true
			return @effect
		elseif @startTime > line.duration or @endTime < @startTime
			return ""
		elseif @accel == 1
			return ("\\t(%s,%s,%s)")\format @startTime, @endTime, @effect
		else
			return ("\\t(%s,%s,%s,%s)")\format @startTime, @endTime, @accel, @effect

	gatherTagsInEffect: =>
		@effectTags = {}
		for name, tag in pairs tags.allTags
			@effect = @effect\gsub tag.pattern, ( value ) ->
				if tag.transformable and not @effectTags[name]
					@effectTags[name] = tag\convert value
					return nil
				else
					return ""

	collectPriorState: ( line = @parentLine ) =>
		@priorValues = { k, v for k, v in pairs line.properties }
		-- Fill out all of the possible tag defaults for tags that aren't
		-- defined by styles. This works great for everything except \clip,
		-- which defaults to 0,0,width,height
		for tagName, tag in ipairs tags.allTags
			if tag.transformable and not tag.style
				@priorValues[tagName] = 0

		@priorValues.rectClip  = { 0, 0, line.parentCollection.meta.PlayResX, line.parentCollection.meta.PlayResY }
		@priorValues.rectiClip = { 0, 0, line.parentCollection.meta.PlayResX, line.parentCollection.meta.PlayResY }

		unless @index
			log.windowError "An error has occurred with transform\ninterpolation in line #{line.humanizedNumber}."

		major = math.floor @index

		line\runCallbackOnOverrides ( line, tagBlock, number ) ->
			for tagName, oldVal in pairs @effectTags
				tag = tags.allTags[tagName]
				tagBlock\gsub tag.pattern, ( value ) ->
					@priorValues[tagName] = tag\convert value

				if tag.affectedBy
					for otherTag in *tag.affectedBy
						newTag = tags.allTags[otherTag]
						tagBlock\gsub newTag.pattern, ( value ) ->
							@priorValues[tagName] = newTag\convert value,
			major

	interpolate: ( time ) =>
		linearProgress = (time - @startTime)/(@endTime - @startTime)
		if linearProgress <= 0
			return ""
		elseif linearProgress >= 1
			return @effect

		progress = math.pow linearProgress, @accel

		for tagName, endValue in pairs @effectTags
			tag = tags.allTags[tagName]
			startValue = @priorValues[tagName]
			interpValue = tag\interpolate startValue, endValue, progress
			-- This is an atrocity against god and man
			@effect = @effect\gsub tag.pattern, ->
				return tag\format interpValue

		return @effect

	__tostring: => return @toString!


