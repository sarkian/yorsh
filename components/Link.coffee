React = require 'react'
router = require '../browser/router'


Link = React.createClass(
    
    getDefaultProps: ->
        params: {}
        
    onClick: (e) ->
        e.preventDefault()
        router.go(@props.view, @props.params)
        
    render: ->
        url = router.url(@props.view, @props.params)
        `<a href={url} onClick={this.onClick} {...this.props}>
            {this.props.children}
        </a>`
    
)


module.exports = Link
