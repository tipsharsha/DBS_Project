import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import SideNavbar from './SideNavbar';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchUsers = async () => {
      // console.log("Fetching users...");
      try {
        const response = await axios.get('http://localhost:3000/usersNotFollowed', { withCredentials: true });
        if (Array.isArray(response.data)) {
          setUsers(response.data);
        } else {
          console.error('Error: Expected an array of users');
          setError(new Error('Expected an array of users'));
        }
        setLoading(false);
      } catch (error) {
        console.error('Error fetching users:', error);
        setError(error);
        setLoading(false);
      }
    };

    fetchUsers();
  }, []);

  const handleUserClick = (userId) => {
    navigate('/profile', {
      state: { userId }
    });
  };
  
  const handleFollow = async (userId, event) => {
    event.preventDefault();
    event.stopPropagation();
    console.log("Following user:", userId);
    
    try {
      const response = await axios.post('http://localhost:3000/followUser', 
        { followeeId: userId }, 
        { withCredentials: true }
      );
      if (response.data.message === 'success') {
        setUsers(users.filter(user => user.user_id !== userId));
      } else {
        console.error("Unexpected response:", response);
      }
    } catch (error) {
      console.error("Error following user:", error);
    }
  };

  if (loading) {
    return <div className="ml-64 p-4">Loading...</div>;
  }

  if (error) {
    return <div className="ml-64 p-4">Error: {error.message}</div>;
  }

  if (users.length === 0) {
    return <div className="ml-64 p-4">No users found</div>;
  }

  return (
    <div>
      <SideNavbar />
      <div className="ml-64 p-4">
        <h1 className="text-2xl font-bold mb-4">Users Not Followed</h1>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {users.map(user => (
            <div 
              key={user.user_id} 
              className="bg-white p-4 rounded shadow hover:shadow-lg transition-shadow"
            >
              <div 
                className="flex items-start justify-between cursor-pointer"
                onClick={() => handleUserClick(user.user_id)}
              >
                <div className="flex items-center space-x-4">
                  <img 
                    src={user.profile_photo_url} 
                    alt={user.username} 
                    className="w-16 h-16 rounded-full"
                  />
                  <div className="flex-1">
                    <h2 className="text-xl font-bold">{user.username}</h2>
                    <p className="text-gray-600">{user.bio}</p>
                    <p className="text-gray-500">{user.email}</p>
                  </div>
                </div>
              </div>
              <div className="mt-4 flex justify-end">
                <button 
                  className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition-colors"
                  onClick={(e) => handleFollow(user.user_id, e)}
                >
                  Follow
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Users;