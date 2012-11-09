# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
    
    hint = null
    hint_short = null
    $.ajax
        async: false
        type: "GET"
        url: "/trialregistry/data/" + $('#criterion_datum_id').val() + ".json"
        dataType: "json"
        success: (data) ->
            hint = data.hint
            hint_short = data.hint_short
    $('#hint').attr('title',hint)
    $('#criterion_value').attr('title',hint)
    $('#criterion_value').val(hint_short)
    $('#criterion_value').addClass("hint")
    
    $('#criterion_datum_id').change ->
        hint = null
        hint_short = null
        $.ajax
            async: false
            type: "GET"
            url: "/trialregistry/data/" + $('#criterion_datum_id').val() + ".json"
            dataType: "json"
            success: (data) ->
                hint = data.hint
                hint_short = data.hint_short
        $('#hint').attr('title',hint)
        $('#criterion_value').attr('title',hint)
        $('#criterion_value').val(hint_short)
        $('#criterion_value').addClass("hint")

    $('#criterion_value').bind "click focusin", ->
        $('#criterion_value').val('')
        $('#criterion_value').removeClass("hint")
