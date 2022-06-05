import React from 'react';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger'
import Popover from 'react-bootstrap/Popover'
import { signOut } from "firebase/auth";
import { auth } from '../firebase';
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBuildingColumns, faMoneyCheckDollar, faUser } from '@fortawesome/free-solid-svg-icons'
import { faHouse } from '@fortawesome/free-solid-svg-icons'

const Sidebar = () => {
  return (
    <div className="w-20 h-full shadow-md bg-white px-1 fixed flex flex-col justify-between">
      <div className="flex flex-col items-center">
        <Link to="/" className="pt-4 pb-4">
          <FontAwesomeIcon icon={faHouse} size="2x" className="text-sky-500" />
        </Link>
        <Link to="/transactions" className="pb-4">
          <FontAwesomeIcon icon={faMoneyCheckDollar} size="2x" className="text-sky-500" />
        </Link>
        <Link to="/banks" className="pb-4">
          <FontAwesomeIcon icon={faBuildingColumns} size="2x" className="text-sky-500" />
        </Link>
      </div>
      <div className="flex flex-col items-center pb-4">
        <OverlayTrigger trigger='click' rootClose placement="right" overlay={popover}>
          <div>
            <FontAwesomeIcon icon={faUser} size="2x" className="text-sky-500" />
          </div>
        </OverlayTrigger>
      </div>
    </div>
  )
}

const popover = (
  <Popover>
    <Popover.Body>
      <ul className="p-0 m-0 text-center">
        <li className="pb-2 px-2 cursor-pointer border-b border-gray-200 dark:border-gray-600">Settings</li>
        <li className="pt-2 px-2 cursor-pointer">
          <button onClick={() => signOut(auth)}>Logout</button>
        </li>
      </ul>
    </Popover.Body>
  </Popover>
);

export default Sidebar