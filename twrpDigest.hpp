/*
	Copyright 2016 bigbiff/Dees_Troy TeamWin
	This file is part of TWRP/TeamWin Recovery Project.

	TWRP is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	TWRP is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with TWRP.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _TWRPDIGEST_HPP_HEADER
#define _TWRPDIGEST_HPP_HEADER

#include <string>

extern "C" {
	#include "digest/md5.h"
}

/* verify_md5digest return codes */
enum {
	MD5_MATCH_FAIL = -2, // -2: md5 did not match
	MD5_NOT_FOUND,       // -1: no md5 file found
	MD5_OK,              //  0: md5 matches
	MD5_FILE_UNREADABLE  //  1: md5 file unreadable
};

using namespace std;

class twrpDigest
{
public:
	void setfn(const string& fn);
	int computeMD5(void);
	int verify_md5digest(void);
	int write_md5digest(void);
	int updateMD5stream(unsigned char* stream, int len);
	void finalizeMD5stream(void);
	string createMD5string(void);
	void initMD5(void);

private:
	int read_md5digest(void);
	struct MD5Context md5c;
	string md5fn;
	string line;
	unsigned char md5sum[MD5LENGTH];
	string md5string;
};

#endif // _TWRPDIGEST_HPP_HEADER
