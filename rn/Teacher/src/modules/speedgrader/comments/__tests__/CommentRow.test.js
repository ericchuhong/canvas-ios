// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import CommentRow, { type CommentRowProps } from '../CommentRow'

const testComment: CommentRowProps = {
  key: 'comment-33',
  name: 'Higgs Boson',
  date: new Date('2017-03-17T19:15:25Z'),
  avatarURL: 'http://fillmurray.com/200/300',
  from: 'them',
  contents: { type: 'comment', message: 'I just need more time!?' },
}

test('Their message rows render correctly', () => {
  let tree = renderer.create(
    <CommentRow {...testComment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('My message rows render correctly', () => {
  const comment = {
    ...testComment,
    from: 'me',
    contents: { type: 'comment', message: `You're too late!` },
  }
  let tree = renderer.create(
    <CommentRow {...comment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('my media comments render correclty', () => {
  const comment = {
    ...testComment,
    from: 'me',
    contents: { type: 'media_comment' },
  }
  let tree = renderer.create(
    <CommentRow {...comment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('their media comments render correctly', () => {
  const comment = {
    ...testComment,
    contents: { type: 'media_comment' },
  }
  let tree = renderer.create(
    <CommentRow {...comment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('their submissions render correctly', () => {
  const comment = {
    ...testComment,
    contents: { type: 'submission' },
  }
  let tree = renderer.create(
    <CommentRow {...comment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
