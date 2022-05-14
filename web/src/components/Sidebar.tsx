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

const Sidebar = () => (
  <div className="w-20 h-full shadow-md bg-white px-1 absolute flex flex-col justify-between">
    <div className="flex flex-col items-center">
      <Link to="/" className="pt-5 pb-5">
        <FontAwesomeIcon icon={faHouse} size="2x" />
      </Link>
      <Link to="/transactions" className="pb-5">
        <FontAwesomeIcon icon={faDollarSign} size="2x" />
      </Link>
      <Link to="/banks" className="pb-5">
        <FontAwesomeIcon icon={faBuildingColumns} size="2x" />
      </Link>
    </div>
    <div className="flex flex-col items-center pb-5">
      <OverlayTrigger trigger='click' rootClose placement="right" overlay={popover}>
        <img src="https://mdbcdn.b-cdn.net/img/new/avatars/8.webp" className="rounded-full w-10" alt="Avatar" />
      </OverlayTrigger>
    </div>
  </div>
)

const popover = (
  <Popover id="popover-basic">
    <Popover.Body>
      <div className="m-2 p-2 w-60 bg-white border border-sky-600 rounded">
        <div><button onClick={() => signOut(auth)}>Logout</button></div>
      </div>
    </Popover.Body>
  </Popover>
);

export default Sidebar