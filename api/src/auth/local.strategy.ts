import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport"
import { Strategy } from "passport-local";
import { AuthService } from "./auth.service";
import { User } from "../user/user.entity";

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {

    constructor(private authService: AuthService) {
        super({ usernameField: 'email' })
    }

    async validate(email: string, password: string): Promise<User> {
        // check if user is valid
        const user = await this.authService.validateUser(email, password)
        // if not, throw an exception
        if ( !user ) {
            throw new UnauthorizedException()
        }
        // if ok, return user info
        return user
    }

}