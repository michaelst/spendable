import React from 'react';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger'
import Popover from 'react-bootstrap/Popover'
import { signOut } from "firebase/auth";
import { auth } from '../firebase';
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBuildingColumns } from '@fortawesome/free-solid-svg-icons'
import { faDollarSign } from '@fortawesome/free-solid-svg-icons'
import { faHouse } from '@fortawesome/free-solid-svg-icons'

const Sidebar = () => {
  return (
    <div className="w-20 h-full shadow-md bg-white px-1 fixed flex flex-col justify-between">
      <div className="flex flex-col items-center">
        <Link to="/" className="pt-4 pb-4">
          <FontAwesomeIcon icon={faHouse} size="2x" />
        </Link>
        <Link to="/transactions" className="pb-4">
          <FontAwesomeIcon icon={faDollarSign} size="2x" />
        </Link>
        <Link to="/banks" className="pb-4">
          <FontAwesomeIcon icon={faBuildingColumns} size="2x" />
        </Link>
      </div>
      <div className="flex flex-col items-center pb-4">
        <OverlayTrigger trigger='click' rootClose placement="right" overlay={popover}>
          <img src="https://mdbcdn.b-cdn.net/img/new/avatars/8.webp" className="rounded-full w-10" alt="Avatar" />
        </OverlayTrigger>
      </div>
    </div>
  )
}

const popover = (
  <Popover>
    <Popover.Body>
      <ul className="w-48 text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white">
        <li className="w-full px-4 py-2 hover:bg-gray-500 cursor-pointer border-b border-gray-200 rounded-t-lg dark:border-gray-600">Profile</li>
        <li className="w-full px-4 py-2 hover:bg-gray-500 cursor-pointer border-b border-gray-200 dark:border-gray-600">Settings</li>
        <li className="w-full px-4 py-2 hover:bg-gray-500 cursor-pointer border-b border-gray-200 dark:border-gray-600">Messages</li>
        <li className="w-full px-4 py-2 hover:bg-gray-500 cursor-pointer rounded-b-lg">
          <button onClick={() => signOut(auth)}>Logout</button>
        </li>
      </ul>
    </Popover.Body>
  </Popover>
);

export default Sidebar