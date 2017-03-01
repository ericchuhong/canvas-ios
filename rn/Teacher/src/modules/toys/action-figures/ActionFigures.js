// @flow

import React, { Component, PropTypes } from 'react'
import { View, Text } from 'react-native'
import { connect } from 'react-redux'
import { stateToProps } from './props'

class ActionFigures extends Component {
  render (): React.Element<*> {
    return (
      <View>
        <Text>We are currently not selling action figures. Maybe you would like some Lego Sets?</Text>
      </View>
    )
  }
}

const actionFigureShape = PropTypes.shape({
  name: PropTypes.string.isRequired,
}).isRequired

ActionFigures.propTypes = {
  actionFigures: PropTypes.arrayOf(actionFigureShape).isRequired,
}

export default connect(stateToProps)(ActionFigures)
