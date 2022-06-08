import React from 'react'

export type RowProps = {
  leftSide: string
  rightSide: string
}

const Row = ({ leftSide, rightSide }: RowProps) => {
  return (
    <div className="flex flex-row justify-between">
      <div className="flex items-center">
        {leftSide}
      </div>
      <div className="flex items-center">
        <div className="flex flex-col items-end">
          {rightSide}
        </div>
      </div>
    </div>
  )
}

export default Row
