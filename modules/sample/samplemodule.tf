variable "yourname" {}


data "template_file" "sampleInput" {
	template = "${file("${path.module}/files/sampleInput.json")}"
	vars {
		name = "${var.yourname}"
	}
}

output "sampleInput" {
	value = "${data.template_file.sampleInput.rendered}"
}