//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import {
  StyleSheet,
  TouchableHighlight,
  Image,
  View,
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import Row from '../../common/components/rows/Row'
import images from '../../images'
import colors from '../../common/colors'
import { Circle } from 'react-native-progress'
import bytes from 'bytes'
import i18n from 'format-message'
import { type Progress } from 'instructure-canvas-api'

export type Props = {
  title: string,
  progress: Progress,
  error: ?string,
  testID: string,
  onRemovePressed: () => void,
  onPress: () => void,
  onRetry: () => void,
  onCancel: () => void,
}

export default class AttachmentRow extends Component<any, Props, any> {
  render () {
    return (
      <Row
        title={this.props.title}
        subtitle={this.renderSubtitle()}
        renderImage={this.renderImage}
        accessories={this.removeButton()}
        onPress={this.props.onPress}
        testID={this.props.testID}
      />
    )
  }

  renderSubtitle () {
    if (this.props.error) return null
    const { loaded, total } = this.props.progress
    const bytesOpts = {
      decimalPlaces: 0,
      unitSeparator: ' ',
    }
    if (total > 0) {
      if (loaded >= total) {
        return bytes(total, bytesOpts)
      }
      return i18n('Uploading {loaded} of {total}', {
        loaded: bytes(loaded, bytesOpts),
        total: bytes(total, bytesOpts),
      })
    }

    return null
  }

  renderImage = () => {
    if (this.props.error) {
      return (
        <TouchableHighlight
          testID={`${this.props.testID}.icon.error`}
          underlayColor='transparent'
          onPress={this.onPressError}
          style={style.image}
          hitSlop={{ top: 12, right: 12, bottom: 12, left: 12 }}
        >
          <Image
            source={images.attachments.error}
            style={style.image}
          />
        </TouchableHighlight>
      )
    }

    if (this.props.progress.loaded >= this.props.progress.total) {
      return (
        <Image
          source={images.attachments.complete}
          style={style.image}
          testID={`${this.props.testID}.icon.complete`}
        />
      )
    }

    return (
      <TouchableHighlight
        testID={`${this.props.testID}.icon.progress`}
        underlayColor='transparent'
        onPress={this.props.onCancel}
        style={style.image}
        hitSlop={{ top: 12, right: 12, bottom: 12, left: 12 }}
      >
        <View style={{ flex: 1, justifyContent: 'center' }}>
          <View style={style.cancel}>
            <View
              style={[style.cancelInner, { backgroundColor: colors.primaryBrandColor }]}
            >
            </View>
          </View>
          <Circle
            size={24}
            borderWidth={0}
            thickness={2}
            progress={this.props.progress.loaded / this.props.progress.total}
            unfilledColor={'#F5F5F5'}
            borderColor={colors.primaryBrandColor}
            color={colors.primaryBrandColor}
          />
        </View>
      </TouchableHighlight>
    )
  }

  removeButton = () => {
    return (
      <TouchableHighlight
        onPress={this.onPressRemove}
        underlayColor='white'
        hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
        testID={`${this.props.testID}.remove.btn`}
      >
        <Image source={images.x} style={style.remove} />
      </TouchableHighlight>
    )
  }

  onPressError = () => {
    ActionSheetIOS.showActionSheetWithOptions({
      options: [
        i18n('Retry Upload'),
        i18n('Delete'),
        i18n('Cancel'),
      ],
      destructiveButtonIndex: 1,
      cancelButtonIndex: 2,
    }, (i) => [this.props.onRetry, this.props.onRemovePressed, () => {}][i]())
  }

  onPressRemove = () => {
    AlertIOS.alert(
      i18n('Remove this attachment?'),
      i18n('This action can not be undone.'),
      [
        { text: i18n('Cancel'), onPress: null, style: 'cancel' },
        { text: i18n('Remove'), onPress: this.props.onRemovePressed, style: 'destructive' },
      ],
    )
  }
}

const style = StyleSheet.create({
  remove: {
    width: 14,
    height: 14,
    tintColor: 'black',
  },
  image: {
    marginRight: global.style.defaultPadding,
  },
  cancel: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cancelInner: {
    width: 6,
    height: 6,
  },
})
