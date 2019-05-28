/*
 * SwerveDrive.h
 *
 *  Created on: 2019. 5. 28.
 *      Author: colson
 *      email: dud3722000@naver.com
 *      email: colson@korea.ac.kr
 *      name: YeongJunKim
 */

#ifndef _ROS_aucar_msgs_SwerveDrive_h
#define _ROS_aucar_msgs_SwerveDrive_h

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "ros/msg.h"

namespace aucar_msgs
{
	class SwerveDrive : public ros::Msg
	{

	};

	virtual int serialize(unsigned char *outbuffer) const
	{

	}
	virtual int deserialize(unsigned char *inbuffer)
	{

	}



	const char * getType(){ return "aucar_msgs/SwerveDrive"; };
	const char * getMD5(){ return "abababababdedededede121212121233"; };
}



#endif /* AUCAR_MSGS_SWERVEDRIVE_H_ */
