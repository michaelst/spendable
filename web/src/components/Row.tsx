import React from 'react'

export type RowProps = {
  key: string
  leftSide: string
  rightSide: string
}

const Row = ({ leftSide, rightSide }: RowProps) => {
  return (
    <div className="flex flex-row justify-between">
      <div className="flex items-center">
        <p>{leftSide}</p>
      </div>
      <div className="flex items-center">
        <div className="flex flex-col items-end">
          <p>{rightSide}</p>
        </div>
      </div>
    </div>
  )
}

export default Row
