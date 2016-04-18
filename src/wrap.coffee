assign = require('lodash/assign')
constants = require('./constants')
isObject = require('lodash/isObject')
wrapFetch = require('./wrapFetch')

class Wrap
	constructor: (resource, @_client) ->
		assign(@, resource)
		@_wrapUrl = "#{@_client.baseUrl}/wraps/#{@id}"

	_createCardMap: (sourceCards, targetCards) ->
		cardMap = {}
		sourceCards.forEach((card, index) -> cardMap[card.id] = targetCards[index].id)
		return cardMap

	_convertSchemaMapToCards: (schemaMap) ->
		for id, schema of schemaMap
			{ id, schema }

	_assignTargetIds: (sourceCards, targetCards) ->
		cardMap = @_createCardMap(@cards, targetCards)
		for card in sourceCards
			card.id = cardMap[card.id]
		return sourceCards

	_convertCardsToSchemaMap: (cards) ->
		cardMap = {}
		cards.forEach((card, index) -> cardMap[card.id] = card.schema)
		return cardMap

	_createPersonalizedWrap: (body) ->
		return wrapFetch.post("#{@_wrapUrl}/personalize", {
			headers: @_client.getAuthHeader()
			body
		}).then((wrap) => new Wrap(wrap, @_client))

	listPersonalized: (search) ->
		return wrapFetch.get("#{@_wrapUrl}/personalize", {
			headers: @_client.getAuthHeader()
			search
		}).then((wraps) =>
			return wraps.map((wrap) => new Wrap(wrap, @_client))
		)

	createPersonalized: (schemaMap, tags) ->
		@_client.getWrap(@id, { published: true })
			.then((publishedWrap) =>
				body = { tags }
				if isObject(schemaMap)
					cards = @_convertSchemaMapToCards(schemaMap)
					cards = @_assignTargetIds(cards, publishedWrap.cards)
					body.personalized_json = @_convertCardsToSchemaMap(cards)
				else
					body.url = schemaMap
				return @_createPersonalizedWrap(body)
			)

	deletePersonalized: (body) ->
		return wrapFetch.delete("#{@_wrapUrl}/personalize", {
			headers: @_client.getAuthHeader()
			body
		})

	share: (mobileNumber, body) ->
		return wrapFetch.get("#{@_wrapUrl}/share", {
			headers: @_client.getAuthHeader()
			search: {
				type: constants.MESSAGE_SERVICES.SMS
				phone_number: mobileNumber
				body
			}
		})

module.exports = Wrap
