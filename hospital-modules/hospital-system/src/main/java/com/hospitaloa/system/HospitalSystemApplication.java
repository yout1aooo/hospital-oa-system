package com.hospitaloa.system;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.hospitaloa.common.security.annotation.EnableCustomConfig;
import com.hospitaloa.common.security.annotation.EnableRyFeignClients;

/**
 * 系统模块
 * 
 * @author hospital-oa-system
 */
@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication(scanBasePackages = {"com.hospitaloa.system", "com.hospitaloa.oa"})
public class HospitalSystemApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(HospitalSystemApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  系统模块启动成功   ლ(´ڡ`ლ)ﾞ  \n" +
                " .-------.       ____     __        \n" +
                " |  _ _   \\      \\   \\   /  /    \n" +
                " | ( ' )  |       \\  _. /  '       \n" +
                " |(_ o _) /        _( )_ .'         \n" +
                " | (_,_).' __  ___(_ o _)'          \n" +
                " |  |\\ \\  |  ||   |(_,_)'         \n" +
                " |  | \\ `'   /|   `-'  /           \n" +
                " |  |  \\    /  \\      /           \n" +
                " ''-'   `'-'    `-..-'              ");
    }
}
