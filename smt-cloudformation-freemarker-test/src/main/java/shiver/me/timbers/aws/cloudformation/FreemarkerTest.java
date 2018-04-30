/*
 *    Copyright 2018 Karl Bennett
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package shiver.me.timbers.aws.cloudformation;

import freemarker.cache.ClassTemplateLoader;
import freemarker.cache.MultiTemplateLoader;
import freemarker.cache.TemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.TemplateException;
import org.apache.commons.io.IOUtils;
import org.junit.Test;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;

import static freemarker.template.Configuration.VERSION_2_3_28;
import static java.lang.ClassLoader.getSystemClassLoader;
import static org.hamcrest.Matchers.equalTo;
import static org.junit.Assert.assertThat;

public class FreemarkerTest {

    @Test
    public void Can_render_a_Cloudformation_template() throws IOException, TemplateException {

        // Given
        final Configuration configuration = new Configuration(VERSION_2_3_28);
        configuration.setTemplateLoader(new MultiTemplateLoader(new TemplateLoader[]{
            new ClassTemplateLoader(getSystemClassLoader(), "/shiver/me/timbers/aws/cloudformation"),
            new ClassTemplateLoader(getSystemClassLoader(), "/")
        }));
        final ByteArrayOutputStream output = new ByteArrayOutputStream();

        // When
        configuration.getTemplate("test-template.ftl").process(null, new OutputStreamWriter(output));

        // Then
        assertThat(normalise(output.toString()), equalTo(normalise(toString("test-template.json"))));
    }

    private String normalise(String string) {
        return string.replaceAll(System.lineSeparator(), "").replaceAll(" +", "").trim();
    }

    private String toString(String path) throws IOException {
        return IOUtils.toString(getSystemClassLoader().getResourceAsStream(path), "UTF-8");
    }
}
