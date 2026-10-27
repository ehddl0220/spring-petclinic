package org.springframework.samples.petclinic.system;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model; // 💡 추가됨
import org.springframework.web.bind.annotation.GetMapping;
import java.net.InetAddress;          // 💡 추가됨
import java.net.UnknownHostException; // 💡 추가됨

@Controller
class WelcomeController {

	@GetMapping("/")
	public String welcome(Model model) { // 💡 파라미터에 Model 추가
		String containerName = "Unknown Container";

		try {
			// 쿠버네티스 환경에서 호스트네임(파드 이름)을 실시간으로 가져옵니다.
			containerName = InetAddress.getLocalHost().getHostName();
		} catch (UnknownHostException e) {
			containerName = "Localhost (Error)";
		}

		// 💡 안전하게 컨트롤러에서 HTML로 데이터를 전달합니다.
		model.addAttribute("containerName", containerName);

		return "welcome";
	}

}
